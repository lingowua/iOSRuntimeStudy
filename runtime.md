## Runtime 学习

### Runtime介绍

> Objective-C 扩展了 C 语言，并加入了面向对象特性和 Smalltalk 式的消息传递机制。而这个扩展的核心是一个用 C 和 编译语言 写的 Runtime 库。它是 Objective-C 面向对象和动态机制的基石。

> Objective-C 是一个动态语言，这意味着它不仅需要一个编译器，也需要一个运行时系统来动态得创建类和对象、进行消息传递和转发。理解 Objective-C 的 Runtime 机制可以帮我们更好的了解这个语言，适当的时候还能对语言进行扩展，从系统层面解决项目中的一些设计或技术问题。了解 Runtime ，要先了解它的核心 - 消息传递 （Messaging）。

`Runtime`其实有两个版本: “`modern`” 和 “`legacy`”。我们现在用的 `Objective-C 2.0` 采用的是现行 (`Modern`) 版的 `Runtime` 系统，只能运行在 `iOS` 和 `macOS 10.5` 之后的 `64` 位程序中。而 `macOS` 较老的`32`位程序仍采用 `Objective-C 1` 中的（早期）`Legacy` 版本的 `Runtime` 系统。这两个版本最大的区别在于当你更改一个类的实例变量的布局时，在早期版本中你需要重新编译它的子类，而现行版就不需要。

`Runtime` 基本是用 `C` 和`汇编`写的，可见苹果为了动态系统的高效而作出的努力。你可以在[这里](https://opensource.apple.com/source/objc4/)下到苹果维护的开源代码。苹果和GNU各自维护一个开源的 [runtime](https://github.com/RetVal/objc-runtime) 版本，这两个版本之间都在努力的保持一致。

平时的业务中主要是使用[官方Api](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)，解决我们框架性的需求。

高级编程语言想要成为可执行文件需要先编译为汇编语言再汇编为机器语言，机器语言也是计算机能够识别的唯一语言，但是`OC`并不能直接编译为汇编语言，而是要先转写为纯`C`语言再进行编译和汇编的操作，从`OC`到`C`语言的过渡就是由runtime来实现的。然而我们使用`OC`进行面向对象开发，而`C`语言更多的是面向过程开发，这就需要将面向对象的类转变为面向过程的结构体。



首先看一下 源码里面对于 类以及对象 的定义 

这里需要注意一点：网上的教程大部分都是 `runtime.h` 里面的代码，但是这里大部分代码已经被注释废弃了就不参考了，详情可查看 [objc_class深深的误解 ](https://www.cnblogs.com/dahe007/p/10566033.html)



```c++
// 对象的定义  objc-private.h
struct objc_object {
private:
    isa_t isa;
public:
    // ISA() assumes this is NOT a tagged pointer object
    Class ISA(bool authenticated = false);
    // rawISA() assumes this is NOT a tagged pointer object or a non pointer ISA
    Class rawISA();
    // getIsa() allows this to be a tagged pointer object
    Class getIsa();
    // 省略了很多细节，具体可在原码中查看
    uintptr_t sidetable_retainCount();
};
```

```C++
// 类的定义 objc-runtime-new.h
struct objc_class : objc_object {
  objc_class(const objc_class&) = delete;
  objc_class(objc_class&&) = delete;
  void operator=(const objc_class&) = delete;
  void operator=(objc_class&&) = delete;
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
  	// 省略了很多细节，具体可在原码中查看
    unsigned classArrayIndex() {
        return bits.classArrayIndex();
    }
};

```

其中 `objc-object` 结构体最关键的就是 `isa` 属性，可以看到属于 `isa_t` 结构，可在源码中看具体定义

```C++
// isa_t 的定义 objc-private.h
union isa_t {
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }
    uintptr_t bits;
private:
    // Accessing the class requires custom ptrauth operations, so
    // force clients to go through setClass/getClass by making this
    // private.
    Class cls;
public:
#if defined(ISA_BITFIELD)
    struct {
        ISA_BITFIELD;  // defined in isa.h
    };
    bool isDeallocating() {
        return extra_rc == 0 && has_sidetable_rc == 0;
    }
    void setDeallocating() {
        extra_rc = 0;
        has_sidetable_rc = 0;
    }
#endif
    void setClass(Class cls, objc_object *obj);
    Class getClass(bool authenticated);
    Class getDecodedClass(bool authenticated);
};
```

可以看到 `isa_t` 是一个共用体，包含了`ISA_BITFIELD`是一个宏(结构体)，`bits`是`uintptr_t`类型，`uintptr_t`其实是`unsign long`类型占用8字节，就是64位，我们进入到`ISA_BITFIELD`内部：

```c++
// uintptr_t 的定义  _uintptr_t.h
typedef unsigned long           uintptr_t;
```

```c++
// ISA_BITFIELD 的定义  isa.h
#define ISA_MASK        0x0000000ffffffff8ULL
#define ISA_MAGIC_MASK  0x000003f000000001ULL
#define ISA_MAGIC_VALUE 0x000001a000000001ULL
#define ISA_HAS_CXX_DTOR_BIT 1
#define ISA_BITFIELD
	uintptr_t nonpointer        : 1;	// 是否为 Tagged pointer
	uintptr_t has_assoc         : 1;	// 是否有关联对象
	uintptr_t has_cxx_dtor      : 1;	// 是否有C++的析构函数（.cxx_destruct）
	uintptr_t shiftcls          : 33; // 存储Class、Meta-Class对象的内存地址
	uintptr_t magic             : 6;	// 
	uintptr_t weakly_referenced : 1;	// 是否被弱引用过
	uintptr_t unused            : 1;	// 
	uintptr_t has_sidetable_rc  : 1;	// 引用计数器是否过大无法存储在isa中 
	uintptr_t extra_rc          : 19	// 里面存储的值是引用计数器减1
#define RC_ONE   (1ULL<<56)
#define RC_HALF  (1ULL<<7)
#endif
```

这里 在不同平台（`arm`、`x86_64`等）下，对于 `ISA_BITFIELD` 的定义是不同的，不过对于学习原理来说，简单看一个就行，我这里截取的是iOS真机下的相关规则

其中，`isa & ISA_MASK` 就是将 `shiftcls`的值取出来，而`shiftcls`里存储的就是`class`对象、`meta-class`对象的地址 [参考](https://zhuanlan.zhihu.com/p/370427824)

其中有几个字段都和对象的释放有关，这里可以看下释放对象的源码

```C++
// 释放对象 objc-runtime-new.mm
void *objc_destructInstance(id obj) {
    if (obj) {
        // Read all of the flags at once for performance.
        bool cxx = obj->hasCxxDtor();
        bool assoc = obj->hasAssociatedObjects();
        // This order is important.
        if (cxx) object_cxxDestruct(obj);
        if (assoc) _object_remove_assocations(obj, /*deallocating*/true);
        obj->clearDeallocating();
    }
    return obj;
}
```

可以看出，释放时候，会先判断是否有设置过关联对象，如果没有，释放时会更快。 是否有`C++`的析构函数`(.cxx_destruct)`，如果没有，释放时会更快。其他的弱引用，`nonpointer`等，读者可自行看源码。

关于[Tagged Pointer](https://github.com/lingowua/iOSRuntimeStudy/blob/main/TaggedPointer.md)技术

### 







