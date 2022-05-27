//
//  Person.m
//  objc_test
//
//  Created by lingowu on 2022/4/28.
//

#import "Person.h"

@implementation Person

- (void)hello {
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
