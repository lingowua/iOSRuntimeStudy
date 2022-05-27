//
//  Person+Extension.h
//  objc_test
//
//  Created by lingowu on 2022/4/29.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person ()

@property (nonatomic, copy) NSString *ext_name;
@property (nonatomic, copy) NSString *ext_subject;

- (void)extH_method;

@end

NS_ASSUME_NONNULL_END
