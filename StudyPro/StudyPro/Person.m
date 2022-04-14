//
//  Person.m
//  StudyPro
//
//  Created by lingowu on 2022/3/31.
//

#import <objc/runtime.h>
#import "Person.h"
#import "StudyProConst.h"

@implementation Person

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }
- (void)show { LGLog(@"%s : %@", __FUNCTION__, self.name);}

@end


static const char *kNamePro = "name1";

@implementation Person (Cat)
@dynamic name1;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)show { LGLog(@"%s  %@ %@", __FUNCTION__, self.name, self.name1);}
#pragma clang diagnostic pop

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }

- (NSString *)name1 {
    return objc_getAssociatedObject(self, &kNamePro);
}

- (void)setName1:(NSString *)name1 {
    objc_setAssociatedObject(self, &kNamePro, name1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation Person (Cat1)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)show { LGLog(@"%s : %@", __FUNCTION__, self.name); }
#pragma clang diagnostic pop

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { if (self == [Person class]) { LGLog(@"%s", __FUNCTION__); }}

@end
