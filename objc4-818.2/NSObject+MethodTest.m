//
//  NSObject+MethodTest.m
//  StudyPro
//
//  Created by lingowu on 2022/6/9.
//

#import "NSObject+MethodTest.h"
#import <objc/runtime.h>

@implementation NSObject (MethodTest)

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(girlfriend)) {
        NSLog(@"__对象方法动态决议来了%s__", __func__);
        IMP imp = class_getMethodImplementation(self, @selector(spareTire));
        Method meth = class_getInstanceMethod(self, @selector(spareTire));
        const char *type = method_getTypeEncoding(meth);
        return class_addMethod(self, sel, imp, type);
    } else if (sel == @selector(getMarried)) {
        NSLog(@"__类方法动态决议来了%s__", __func__);
        IMP imp = class_getMethodImplementation(self, @selector(blindDate));
        Method meth = class_getClassMethod(self, @selector(blindDate));
        const char *type = method_getTypeEncoding(meth);
         return class_addMethod(object_getClass(self), sel, imp, type);
    }
    return NO;
}

@end
