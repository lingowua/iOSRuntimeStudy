//
//  Student.m
//  StudyPro
//
//  Created by lingowu on 2022/4/8.
//

#import "Student.h"
#import "StudyProConst.h"

@implementation Student

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }
- (void)show { NSLog(@"%s : %@", __FUNCTION__, self.name); }

@end


@implementation GoodStudent

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }
- (void)show { NSLog(@"%s : %@", __FUNCTION__, self.name); }

@end


@implementation Teacher

+ (void)load { LGLog(@"%s", __FUNCTION__); }
+ (void)initialize { LGLog(@"%s", __FUNCTION__); }
- (void)show { NSLog(@"%s : %@", __FUNCTION__, self.name); }

@end
