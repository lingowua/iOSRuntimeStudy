## Tagged Pointer 学习

首先，简单介绍一下 `Tagged Pointer` 的[引入背景](https://blog.devtang.com/2014/05/30/understand-tagged-pointer/)

![img](https://blog.devtang.com/images/tagged_pointer_before.jpg)

![img](https://blog.devtang.com/images/tagged_pointer_after.jpg)

简单来说，对于一些占用内存比较低的基础数据，`NSNumber、NSData、NSString`等类型，可以直接在指针里存取对应的值，即减少了内存占用，同时也不用维护其引用计数，管理生命周期等。

首先，我们先写一段测试代码

```objective-c
NSNumber *n1 = @1, *n2 = @2, *n3 = @3, *n4 = @(0xFFFF);
NSNumber *n5 = @(0xEFFFFFFFFFFFFFFF);
printf("%p %p %p %p\n%p\n\n", n1, n2, n3, n4, n5);
```

输出是

```c++
0x949665684ee5cb5b 0x949665684ee5cb6b 0x949665684ee5cb7b 0x949665684eea34bb
0x6000015c33c0
```

好像和设想的不太对，这里是因为默认开启了`Tagged Pointer`混淆的功能，关于混淆这里，我们也可以先看一下源码

```C++
// TaggedPointer 混淆代码  objc-internal.h
static inline uintptr_t
_objc_decodeTaggedPointer_noPermute(const void * _Nullable ptr)
{
    uintptr_t value = (uintptr_t)ptr;
#if OBJC_SPLIT_TAGGED_POINTERS
    if ((value & _OBJC_TAG_NO_OBFUSCATION_MASK) == _OBJC_TAG_NO_OBFUSCATION_MASK)
        return value;
#endif
    return value ^ objc_debug_taggedpointer_obfuscator;
}

static inline uintptr_t
_objc_decodeTaggedPointer(const void * _Nullable ptr)
{
    uintptr_t value = _objc_decodeTaggedPointer_noPermute(ptr);
#if OBJC_SPLIT_TAGGED_POINTERS
    uintptr_t basicTag = (value >> _OBJC_TAG_INDEX_SHIFT) & _OBJC_TAG_INDEX_MASK;

    value &= ~(_OBJC_TAG_INDEX_MASK << _OBJC_TAG_INDEX_SHIFT);
    value |= _objc_obfuscatedTagToBasicTag(basicTag) << _OBJC_TAG_INDEX_SHIFT;
#endif
    return value;
}
```

可以看到混淆算法，是`地址`和`objc_debug_taggedpointer_obfuscator`进行异或操作。

这里可以有两种方法来解决这个问题：

1. 通过配置环境配置，关闭代码混淆

   `Product->Scheme->Edit Scheme` `CMD + shift + <`  然后在 `Run->Arguments->Environment Variables` 中添加环境变量`OBJC_DISABLE_TAG_OBFUSCATION`为`YES`，关闭数据混淆。

2. 既然，已经知道是通过异或`objc_debug_taggedpointer_obfuscator`来加密，那么自然可以通过再次异或`objc_debug_taggedpointer_obfuscator`来进行解密。这里我简单封装了一下

```objective-c
extern uintptr_t objc_debug_taggedpointer_obfuscator;
#define DTag(num) ((uintptr_t)num ^ objc_debug_taggedpointer_obfuscator)
```



再调整一下测试代码对比一下

```objective-c
NSNumber *n1 = @1, *n2 = @2, *n3 = @3, *n4 = @(0xFFFF);
NSNumber *n5 = @(0xEFFFFFFFFFFFFFFF);
printf("%p %p %p %p\n%p\n\n", n1, n2, n3, n4, n5);
printf("%lx %lx %lx %lx\n%lx\n\n", DTag(n1), DTag(n2), DTag(n3), DTag(n4), DTag(n5));
```

输出为，可以看出来其中 `n1,n2,n3,n4` 的值直接存储在其指针上，`n5`由于数据比较大，则为其分配的堆内存

```c++
0x949665684ee5cb5b 0x949665684ee5cb6b 0x949665684ee5cb7b 0x949665684eea34bb
0x6000015c33c0

b000000000000012 b000000000000022 b000000000000032 b0000000000ffff2
249605684fb9f889
```

同时也可以在调试台对这几个的`isa`指针进行打印，结果如下:

```
(lldb) po n1->isa
error: Couldn't apply expression side effects : Couldn't dematerialize a result variable: couldn't read its memory
(lldb) po n5->isa
__NSCFNumber
```

其中，第一位的`b`代表存储的是`NSNumber`类型，最后一位的`2`代表`NSNumber`里面存储的是`int`类型。这里每一位具体定义可以参考 [iOS 内存管理（二）：tagged pointer原理分析](https://juejin.cn/post/7007030560543473671)

这里还可以简单再测试一下：

```objective-c
char a = 1;
short b = 1;
int c = 1;
long d = 1;
float e = 1.0;
double f = 1.00;

NSNumber *n1 = @(a), *n2 = @(b), *n3 = @(c), *n4 = @(d);
NSNumber *n5 = @(e), *n6 = @(f);
printf("%lx %lx %lx %lx\n%lx %lx\n\n", DTag(n1), DTag(n2), DTag(n3), DTag(n4), DTag(n5), DTag(n6));

// 输出如下
b000000000000010 b000000000000011 b000000000000012 b000000000000013
b000000000000014 b000000000000015
// 可以看出 0:char  1:short  2:int  3:long  4:float  5:double
```



后面，我们再来看一下， `Tagged Pointer` 对于`NSString`的相关优化，这里主要参考了[Tagged Pointer 字符串](https://swift.gg/2018/10/08/tagged-pointer-strings/)

先看一下测试代码以及其输出：

```objective-c
NSString *s1 = [NSString stringWithFormat:@"a"];
NSString *s2 = [NSString stringWithFormat:@"ab"];
NSString *s3 = [NSString stringWithFormat:@"abc"];
NSString *s4 = [NSString stringWithFormat:@"abcd"];
NSString *s5 = [NSString stringWithFormat:@"abcde"];
NSString *s6 = [NSString stringWithFormat:@"abcdef"];
NSString *s7 = [NSString stringWithFormat:@"abcdefg"];
NSString *s8 = [NSString stringWithFormat:@"abcdefgh"];
NSString *s9 = [NSString stringWithFormat:@"abcdefghi"];
NSString *s10 = [NSString stringWithFormat:@"abcdefghij"];
printf("%lx %lx %lx %lx\n", DTag(s1), DTag(s2), DTag(s3), DTag(s4));
printf("%lx %lx %lx %lx\n", DTag(s5), DTag(s6), DTag(s7), DTag(s8));
printf("%lx %lx\n", DTag(s9), DTag(s10));

// 输出如下
a000000000000611 a000000000062612 a000000006362613 a000000646362614
a000065646362615 a006665646362616 a676665646362617 a0022038a0116958
a0880e28045a5419 3ef08a2a3f14dbb
```

通过输出不难看出，第一位`a`代表了存储的是`NSString`类型，最后一位存储的是字符串的长度，但是在字符串不满8位的时候可以很明显看出来，两位对应一个字符并且是 `ASCII` 编码，但是在位数超过7位的时候，编码就看不太出来规律了，根据上面的[文档](https://swift.gg/2018/10/08/tagged-pointer-strings/)得到的结论因此，我们可以得到 `Tagged Pointer` 字符串的结构大致为：

1. 长度在 0 到 7 范围内时，直接保存原始的 8 位字符。
2. 长度为 8 或者 9时， 保存 6 位编码后的字符，编码使用的字母表为 `"eilotrm.apdnsIc ufkMShjTRxgC4013bDNvwyUL2O856P-B79AFKEWV_zGJ/HYX"`
3. 长度大于 10 时，保存 5 位编码后的字符，编码使用的字母表为 `"eilotrm.apdnsIc ufkMShjTRxgC4013"`，即为之前的32位

根据这个我们可以对`Tagged Pointer String` 进行一个解码，代码如下：

```objective-c
// 具体测试代码可以在 StudyPro 项目中的 TaggedPointTest.m 查看
// 解码 Tagged Pointer String 的测试代码
// 去掉最高位和最低的4 bit
#define MASK        0x0ffffffffffffff0ULL
#define TAG_MASK    (1UL <<63)
const NSString *rcx = @"eilotrm.apdnsIc ufkMShjTRxgC4013bDNvwyUL2O856P-B79AFKEWV_zGJ/HYX";

- (void)decodeTaggedPointer:(NSString *)str {
    printf("原字符串: %s\n", [str UTF8String]);
    uintptr_t p = DTag(str);
    if ((p & TAG_MASK) != TAG_MASK) {
        printf("当前字符串不属于 Tagged Pointer 地址为： %lx \n\n", p);
        return;
    }
    
    printf("解码前： %lx \n解码后： ", p);
    // 将最低位的记录字符串个数的数字移除
    uintptr_t num = (p & MASK) >> 4;
    int mask = 0x1f, bit = 5;
    if (7 >= [str length]) {
        mask = 0xff;
        bit = 8;
    } else if (9 >= [str length]) {
        mask = 0x3f;
        bit = 6;
    }
    
    while (num) {
        int idx = num & mask;
        printf("%c", bit == 8 ? idx : [rcx characterAtIndex:idx]);
        num = num >> bit;
    }
    printf("\n\n");
}
```

一些测试代码的输出

```
原字符串: abcdef
解码前： a006665646362616 
解码后： abcdef

原字符串: abcdefg
解码前： a676665646362617 
解码后： abcdefg

原字符串: m.apdnsIc u
解码前： a18e84a96c6b9f0b 
解码后： u cIsndpa.m

原字符串: cdefghijklm
解码前： a39408eaa1b4846b 
解码后： mlkjihgfedc

原字符串: abcdefghij
当前字符串不属于 Tagged Pointer 地址为： 7187c8fdc135d4ec 
```

关于 `Tagged Pointer `字符串还有一段测试代码:

```objective-c
// 不会 crash, 因为循环里面的是 Tagged Pointer String
dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
for (int i = 0; i < 10000; i++) {
  dispatch_async(queue, ^{
    self.name = [NSString stringWithFormat:@"abcdefghi"];
  });
}

// 会 crash, 因为多线程导致的多次释放，解决方案，加锁或者改为 atmoic
for (int i = 0; i < 10000; i++) {
  dispatch_async(queue, ^{
    self.name = [NSString stringWithFormat:@"abcdefghij"];
  });
}

```

至于 `crash` 的原因，默认的`SetName`源码为：

```objective-c
- (void)setName:(NSString *)name {
  	if(_name != name) {
      	[_name release]; 
      	_name = [name retain]; // or [name copy] 
		} 
}
```

其中 `release` 相关源码为：

```objective-c
// 对象内存管理相关代码 NSObject.mm
__attribute__((aligned(16), flatten, noinline))
id 
objc_retain(id obj)
{
    if (obj->isTaggedPointerOrNil()) return obj;
    return obj->retain();
}


__attribute__((aligned(16), flatten, noinline))
void 
objc_release(id obj)
{
    if (obj->isTaggedPointerOrNil()) return;
    return obj->release();
}


__attribute__((aligned(16), flatten, noinline))
id
objc_autorelease(id obj)
{
    if (obj->isTaggedPointerOrNil()) return obj;
    return obj->autorelease();
}
```

可以看出，如果对象如果为 `TaggedPointer`，不会对对象进行内存释放等操作。

 





