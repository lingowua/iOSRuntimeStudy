//
//  Dog.h
//  StudyPro
//
//  Created by lingowu on 2022/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Dog : NSObject

@property(class, nonatomic, copy) NSString *varies;

- (void)bark;
- (void)eat;
- (void)sleep;
- (void)run;

@end

@interface Dog (Cat)

@property(class, nonatomic, copy) NSString *variesd;

@end

@interface Dog (Cat1)

@end

@interface MyObj : NSObject<NSObject>

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) NSInteger age;

@end


@interface MyObjChild : MyObj

@end


@interface MyObjChildChild : MyObjChild

@end

NS_ASSUME_NONNULL_END
