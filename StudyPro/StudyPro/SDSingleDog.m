//
//  SDSingleDog.m
//  objc_test
//
//  Created by lingowu on 2022/6/9.
//

#import "SDSingleDog.h"

extern void instrumentObjcMessageSends(BOOL flag);

@implementation SDSingleDog

- (void)methodTest {
    instrumentObjcMessageSends(YES);
    [self girlfriend];
    [SDSingleDog getMarried];
    instrumentObjcMessageSends(NO);
}

+ (void)blindDate {
    NSLog(@"____The single dog began to blind date____");
}

- (void)spareTire {
    NSLog(@"The single dog becomes spare tire");
}


@end
