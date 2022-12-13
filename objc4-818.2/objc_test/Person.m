//
//  Person.m
//  objc_test
//
//  Created by lingowu on 2022/4/28.
//

#import "Person.h"
#import "XJPerson.h"
#import <objc/runtime.h>

OBJC_EXPORT void
objc_msgSend(void /* id self, SEL op, ... */ )
    OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);

@implementation Person

- (void)hello {
    
    XJPerson *p  = [XJPerson alloc];
    Class pClass = [XJPerson class];
    NSLog(@"%@",pClass);
    [p init];
    [p smileToLife];
    
    
    //给XJPerson分配内存
    XJPerson *person = ((XJPerson *(*)(id, SEL))(void *)objc_msgSend)(objc_getClass("XJPerson"), sel_registerName("alloc"));
    //调用方法
    ((void (*)(id, SEL, NSString * _Nonnull))(void *)objc_msgSend)((id)person, sel_registerName("thatGirlSayToMe:"), @"I love you");

    
    NSLog(@"%s : %@", __FUNCTION__, self.name);
    static dispatch_once_t onceToken;
    NSLog(@"before: %ld--%p",onceToken, &onceToken);
    dispatch_once(&onceToken, ^{
        NSLog(@"after: %ld--%p",onceToken, &onceToken);
    });
    
}
- (void)foo {
    NSLog(@"Doing foo");//Person的foo函数
}

@end
