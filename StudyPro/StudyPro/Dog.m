//
//  Dog.m
//  StudyPro
//
//  Created by lingowu on 2022/4/8.
//

#import <objc/runtime.h>
#import "Dog.h"
#import "StudyProConst.h"

@implementation Dog
@dynamic varies;
static NSString *_varies = @"";

+ (void)load {
    LGLog(@"%s", __FUNCTION__);
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(bark)), class_getInstanceMethod(self, @selector(run)));
    method_setImplementation(class_getInstanceMethod(self, @selector(eat)), class_getMethodImplementation(self, @selector(sleep)));
}
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

- (void)bark { NSLog(@"%s", __FUNCTION__); }
- (void)eat { NSLog(@"%s", __FUNCTION__); }
- (void)sleep { NSLog(@"%s", __FUNCTION__); }
- (void)run { NSLog(@"%s", __FUNCTION__); }

+ (void)setVaries:(NSString *)vari {_varies = vari;}
+ (NSString *)varies { return _varies; }

@end


@implementation Dog (Cat)
@dynamic variesd;
static NSString *_variesd = @"";

+ (void)load { LGLog(@"%s", __FUNCTION__);}
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

+ (void)setVariesd:(NSString *)vari { _variesd = vari;}
+ (NSString *)variesd { return _variesd; }

@end


@implementation Dog (Cat1)

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)bark { NSLog(@"%s", __FUNCTION__); }
- (void)eat { NSLog(@"%s", __FUNCTION__); }
- (void)sleep { NSLog(@"%s", __FUNCTION__); }
- (void)run { NSLog(@"%s", __FUNCTION__); }
#pragma clang diagnostic pop

@end


@implementation MyObj {
    int nIval;//第一处增加
}

+ (void)load {
    LGLog(@"%s", __FUNCTION__);
    return;/*
    //第二处增加
    LGLog(@"-1.------华丽的分隔线-------");
    unsigned int count = 0;
    Class metaClass = object_getClass([MyObj class]);
    Method *methods = class_copyMethodList(metaClass, &count);
    for (int i = 0; i < count; i++) {
        LGLog(@"类方法为：%s", sel_getName(method_getName(methods[i])));
    }
    free(methods);

    LGLog(@"-2.------华丽的分隔线------");
    unsigned int countMethod = 0;
    methods = class_copyMethodList([self class], &countMethod);
    for (int i = 0; i < countMethod; i++) {
        LGLog(@"实例方法为：%s", sel_getName(method_getName(methods[i])));
    }
    free(methods);

    LGLog(@"-3.------华丽的分隔线-------");
    unsigned int countIval = 0;
    Ivar *ivals = class_copyIvarList([self class], &countIval);
    for (int i = 0; i < countIval; i++) {
        LGLog(@"变量为：%s", ivar_getName(ivals[i]));
    }
    free(ivals);
    
    LGLog(@"-4.------华丽的分隔线------");
    unsigned int countProperty = 0;
    objc_property_t *propertys = class_copyPropertyList([self class], &countProperty);
    for (int i = 0; i < countProperty; i++) {
        LGLog(@"属性为：%s", property_getName(propertys[i]));
    }
    free(propertys);
    
    LGLog(@"-5.------华丽的分隔线------");
    unsigned int countProtocol = 0;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList([self class], &countProtocol);
    for (int i = 0; i < countProtocol; i++) {
        LGLog(@"协议为：%s", protocol_getName(protocols[i]));
    }
    LGLog(@"------华丽的分隔线------");
    */
}

- (void)objectFunction {//第三处增加
    LGLog(@"%s",__FUNCTION__);
}

+ (void)classFunction {//第四处增加
    LGLog(@"%s",__FUNCTION__);
}

+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

@end


@implementation MyObjChild

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

@end


@implementation MyObjChildChild

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

@end
