//
//  Person.h
//  objc_test
//
//  Created by lingowu on 2022/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

- (void)hello;

@end

NS_ASSUME_NONNULL_END
