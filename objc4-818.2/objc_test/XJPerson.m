//
//  XJPerson.m
//  objc_test
//
//  Created by lingowu on 2022/6/6.
//

#import "XJPerson.h"

@implementation XJPerson

- (void)loveEveryone {
    NSLog(@"%s", __func__);
}

- (void)smileToLife {
    NSLog(@"%s", __func__);
}

- (void)takeCareFamily {
    NSLog(@"%s", __func__);
}

- (void)thatGirlSayToMe:(NSString *)str {
    NSLog(@"%s   %@", __func__, str);
}
@end
