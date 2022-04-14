//
//  Person.h
//  StudyPro
//
//  Created by lingowu on 2022/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

- (void)show;

@end


@interface Person (Cat)

@property (nonatomic, copy) NSString *name1;

@end


@interface Person (Cat1)

@end

NS_ASSUME_NONNULL_END
