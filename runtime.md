## Runtime 学习

Runtime的特性主要是消息(`方法`)传递，如果消息(`方法`)在对象中找不到，就进行转发，具体怎么实现的呢。我们从下面几个方面探寻Runtime的实现机制。

- Runtime介绍
- Runtime消息传递
- Runtime消息转发
- Runtime应用

### Runtime介绍

> Objective-C 扩展了 C 语言，并加入了面向对象特性和 Smalltalk 式的消息传递机制。而这个扩展的核心是一个用 C 和 编译语言 写的 Runtime 库。它是 Objective-C 面向对象和动态机制的基石。

> Objective-C 是一个动态语言，这意味着它不仅需要一个编译器，也需要一个运行时系统来动态得创建类和对象、进行消息传递和转发。理解 Objective-C 的 Runtime 机制可以帮我们更好的了解这个语言，适当的时候还能对语言进行扩展，从系统层面解决项目中的一些设计或技术问题。了解 Runtime ，要先了解它的核心 - 消息传递 （Messaging）。

`Runtime`其实有两个版本: “`modern`” 和 “`legacy`”。我们现在用的 `Objective-C 2.0` 采用的是现行 (`Modern`) 版的 `Runtime` 系统，只能运行在 `iOS` 和 `macOS 10.5` 之后的 `64` 位程序中。而 `macOS` 较老的`32`位程序仍采用 `Objective-C 1` 中的（早期）`Legacy` 版本的 `Runtime` 系统。这两个版本最大的区别在于当你更改一个类的实例变量的布局时，在早期版本中你需要重新编译它的子类，而现行版就不需要。

`Runtime` 基本是用 `C` 和`汇编`写的，可见苹果为了动态系统的高效而作出的努力。你可以在[这里](https://link.juejin.cn?target=http%3A%2F%2Fwww.opensource.apple.com%2Fsource%2Fobjc4%2F)下到苹果维护的开源代码。苹果和GNU各自维护一个开源的 [runtime](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FRetVal%2Fobjc-runtime) 版本，这两个版本之间都在努力的保持一致。

平时的业务中主要是使用[官方Api](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Freference%2Fobjectivec%2Fobjective_c_runtime%23%2F%2Fapple_ref%2Fdoc%2Fuid%2FTP40001418-CH1g-126286)，解决我们框架性的需求。

高级编程语言想要成为可执行文件需要先编译为汇编语言再汇编为机器语言，机器语言也是计算机能够识别的唯一语言，但是`OC`并不能直接编译为汇编语言，而是要先转写为纯`C`语言再进行编译和汇编的操作，从`OC`到`C`语言的过渡就是由runtime来实现的。然而我们使用`OC`进行面向对象开发，而`C`语言更多的是面向过程开发，这就需要将面向对象的类转变为面向过程的结构体。








