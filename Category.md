### `iOS Category` 详解

一、**概述**

> `Category` 就是对装饰模式的一种具体实现。它的主要作用是在不改变原有类的前提下，动态地给这个类添加一些方法。在 `OC`中的具体体现为：实例（类）方法、属性和协议。

`Category`是`OC 2.0`之后添加的语言特性，`Category`又叫分类、类别、类目，能够在不改变原来类内容的基础上，为类增加一些方法。除此之外，`Category`还有以下功能：

（1）将类的实现分开写在几个分类里面。
这样做的好处:

- 可以减少单个文件的体积
- 可以把不同的功能组织到不同的`Category`里
- 可以由多个开发者共同完成一个类
- 可以按需加载想要的`Category`

（2）声明私有的方法。

（3）模拟多继承。

 

二、**`Category`的定义与使用**

为了便于理解，这里直接通过一个小例子去讲解其用法。

例如，我们创建一个`Person`类，并为其创建一个`Category`命名为`MyCategory`。

为`Person`创建一个名为`MyCategory`的`Category`后，会自动生成`Person+MyCategory.h`和`Person+MyCategory.m`文件。我们在`MyCategory`中声明和实现一个`read`方法，如下：

```objective-c
//  Person+MyCategory.h
#import "Person.h"

@interface Person (MyCategory)

-(void)read;

@end
```

```objective-c
//  Person+MyCategory.m
#import "Person+MyCategory.h"

@implementation Person (MyCategory)

-(void)read {
    NSLog(@"调用了MyCategory的read方法！");
}

@end
```

之后我们可以在`ViewController`或其他地方使用分类中添加的方法，如下：

```objective-c
//  ViewController.m
#import "ViewController.h"
#import "Person+MyCategory.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *p = [[Person alloc] init];
    [p read];
}

@end
```

打印结果：

```
2017-01-09 16:27:39.089 Test[5347:483009] 调用了MyCategory的read方法！
```



### 使用注意

1. 分类只能增加方法，不能增加成员变量。
2. 分类方法实现中可以访问原来类中声明的成员变量。
3. 分类可以重新实现原来类中的方法，但是会覆盖掉原来的方法，会导致原来的方法没法再使用（实际上并没有真的替换，而是Category的方法被放到了新方法列表的前面，而原来类的方法被放到了新方法列表的后面，这也就是我们平常所说的Category的方法会“覆盖”掉原来类的同名方法，这是因为运行时在查找方法的时候是顺着方法列表的顺序查找的，它只要一找到对应名字的方法，就会罢休，殊不知后面可能还有一样名字的方法）。
4. 当分类、原来类、原来类的父类中有相同方法时，方法调用的优先级：分类(最后参与编译的分类优先) –> 原来类 –> 父类，即先去调用分类中的方法，分类中没这个方法再去原来类中找，原来类中没有再去父类中找。
5. `Category`是在`runtime`时候加载，而不是在编译的时候。

三、**`Category`与成员变量、属性**

如果你在你`Category.h`文件中写如下代码：

```objective-c
{
    NSString *str1;
}
```

`Xcode`会报如下错误:

```objective-c
Instance variable may not be placed in categories
```

通过这句话我们知道`Xcode`是不允许我们在`Category`中添加成员变量的。



首先从`Category`的结构体开始分析：

- `instanceMethods`: 实例方法
- `classMethods`:类方法
- `protocols`:协议
- `instanceProperties`:实例属性
- `_classProperties`:类属性

```objective-c
// Category 的定义  objc-runtime-new.h
struct category_t {
    const char *name;
    classref_t cls;
    WrappedPtr<method_list_t, PtrauthStrip> instanceMethods;
    WrappedPtr<method_list_t, PtrauthStrip> classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
    
    protocol_list_t *protocolsForMeta(bool isMeta) {
        if (isMeta) return nullptr;
        else return protocols;
    }
};
```

再看一下，`Category` 的加载过程，

```objective-c
// _objc_init 加载函数  objc-os.mm
/***********************************************************************
* _objc_init
* Bootstrap initialization. Registers our image notifier with dyld.
* Called by libSystem BEFORE library initialization time
**********************************************************************/

void _objc_init(void)
{
    static bool initialized = false;
    if (initialized) return;
    initialized = true;
    
    // fixme defer initialization until an objc-using image is found?
    environ_init();
    tls_init();
    static_init();
    runtime_init();
    exception_init();
#if __OBJC2__
    cache_t::init();
#endif
    _imp_implementationWithBlock_init();

    _dyld_objc_notify_register(&map_images, load_images, unmap_image);

#if __OBJC2__
    didCallDyldNotifyRegister = true;
#endif
}
```

可以看一下这里`load_images`的源码分析

```objective-c
// load_images  objc-runtime-new.mm
void
load_images(const char *path __unused, const struct mach_header *mh)
{
    if (!didInitialAttachCategories && didCallDyldNotifyRegister) {
        didInitialAttachCategories = true;
        loadAllCategories();
    }

    // Return without taking locks if there are no +load methods here.
    if (!hasLoadMethods((const headerType *)mh)) return;

    recursive_mutex_locker_t lock(loadMethodLock);

    // Discover load methods
    {
        mutex_locker_t lock2(runtimeLock);
        prepare_load_methods((const headerType *)mh);
    }

    // Call +load methods (without runtimeLock - re-entrant)
    call_load_methods();
}
```

`load_images` -> `loadAllCategories` -> `load_categories_nolock()` -> `attachCategories` 



```objective-c
// 类的定义 objc-runtime-new.h
struct objc_class : objc_object {
	.......
	class_rw_t *data() const {
        return bits.data();
    }
    ......
}
```



从Category的定义也可以看出Category的可为（可以添加实例方法，类方法，甚至可以实现协议，添加属性）和不可为（无法添加实例变量）。

但是为什么网上很多人都说Category不能添加属性呢？

实际上，Category实际上允许添加属性的，同样可以使用@property，但是不会生成_变量（带下划线的成员变量），也不会生成添加属性的getter和setter方法，所以，尽管添加了属性，也无法使用点语法调用getter和setter方法。但实际上可以使用runtime去实现Category为已有的类添加新的属性并生成getter和setter方法。

```objective-c
// 为分类添加属性的代码
static char *kNamePro;

@dynamic name;

- (NSString *)name {
    return objc_getAssociatedObject(self, &kNamePro);
}
- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, &kNamePro, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
```



我们可以看到所有的关联对象都由`AssociationsManager`管理

```objective-c
// 关联对象  objc-runtime.mm
void
objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
{
    _object_set_associative_reference(object, key, value, policy);
}
```

```objective-c
// 关联对象的管理 objc-references.mm
void
_object_set_associative_reference(id object, const void *key, id value, uintptr_t policy)
{
    // This code used to work when nil was passed for object and key. Some code
    // probably relies on that to not crash. Check and handle it explicitly.
    // rdar://problem/44094390
    if (!object && !value) return;

    if (object->getIsa()->forbidsAssociatedObjects())
        _objc_fatal("objc_setAssociatedObject called on instance (%p) of class %s which does not allow associated objects", object, object_getClassName(object));

    DisguisedPtr<objc_object> disguised{(objc_object *)object};
    ObjcAssociation association{policy, value};

    // retain the new value (if any) outside the lock.
    association.acquireValue();

    bool isFirstAssociation = false;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.get());

        if (value) {
            auto refs_result = associations.try_emplace(disguised, ObjectAssociationMap{});
            if (refs_result.second) {
                /* it's the first association we make */
                isFirstAssociation = true;
            }

            /* establish or replace the association */
            auto &refs = refs_result.first->second;
            auto result = refs.try_emplace(key, std::move(association));
            if (!result.second) {
                association.swap(result.first->second);
            }
        } else {
            auto refs_it = associations.find(disguised);
            if (refs_it != associations.end()) {
                auto &refs = refs_it->second;
                auto it = refs.find(key);
                if (it != refs.end()) {
                    association.swap(it->second);
                    refs.erase(it);
                    if (refs.size() == 0) {
                        associations.erase(refs_it);

                    }
                }
            }
        }
    }

    // Call setHasAssociatedObjects outside the lock, since this
    // will call the object's _noteAssociatedObjects method if it
    // has one, and this may trigger +initialize which might do
    // arbitrary stuff, including setting more associated objects.
    if (isFirstAssociation)
        object->setHasAssociatedObjects();

    // release the old value (outside of the lock).
    association.releaseHeldValue();
}
```

`AssociationsManager`里面是由一个静态`AssociationsHashMap`来存储所有的关联对象的。这相当于把所有对象的关联对象都存在一个全局`map`里面。而`map`的`key`是这个对象的指针地址（任意两个不同对象的指针地址一定是不同的），而这个`map`的`value`又是另外一个`AssociationsHashMap`，里面保存了关联对象的`kv`对。

```objective-c
// AssociationsManager 的定义  objc-references.mm  
typedef DenseMap<const void *, ObjcAssociation> ObjectAssociationMap;
typedef DenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap> AssociationsHashMap;

// class AssociationsManager manages a lock / hash table singleton pair.
// Allocating an instance acquires the lock

class AssociationsManager {
    using Storage = ExplicitInitDenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap>;
    static Storage _mapStorage;

public:
    AssociationsManager()   { AssociationsManagerLock.lock(); }
    ~AssociationsManager()  { AssociationsManagerLock.unlock(); }

    AssociationsHashMap &get() {
        return _mapStorage.get();
    }

    static void init() {
        _mapStorage.init();
    }
};
```





四、**Category与Extension**

1、Extension的基本用法

Extension的创建方法与Category一样，只要在原来选择Category选择Extension即可，比如我们为Person创建一个名为MyExtension的Extension，则最终会生成一个Person_MyExtension.h文件：

```objective-c
//  Person_MyExtension.h

#import "Person.h"

@interface Person ()

@end
```

但要注意的是和Category不同的是它不会生成Person_MyExtension.m文件。之后我们可以在Person_MyExtension.h中**直接添加成员变量、属性和方法**，如下：

```objective-c
//  Person_MyExtension.h

#import "Person.h"

@interface Person () {
    NSString * _address;
}
@property (nonatomic) NSInteger age;

-(NSString*)WhereAmI;

@end
```

 

他常用的形式不是创建一个单独的文件，而是在实现文件中添加私有的成员变量、属性和方法。例如：

```objective-c
//  Person.m

#import "Person.h"

@interface Person () {
    NSString * _address;
}
@property (nonatomic) NSInteger age;

-(NSString*)WhereAmI;

@end


@implementation Person

-(NSString*)WhereAmI {
    return @"谁知道你在哪里";
}

@end
```

 

2、Extension与Category区别

- Extension
  - 在编译器决议，是类的一部分，在编译器和头文件的@interface和实现文件里的@implement一起形成了一个完整的类。
  - 伴随着类的产生而产生，也随着类的消失而消失。
  - Extension一般用来隐藏类的私有消息，你必须有一个类的源码才能添加一个类的Extension，所以对于系统一些类，如NSString，就无法添加类扩展
  
- Category
  - 是运行期决议的
  
  - 类扩展可以添加实例变量，分类不能添加实例变量
  
  - 原因：因为在运行期，对象的内存布局已经确定，如果添加实例变量会破坏类的内部布局，这对编译性语言是灾难性的。
  
    
