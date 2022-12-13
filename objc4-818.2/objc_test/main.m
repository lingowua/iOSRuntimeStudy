//
//  main.m
//  objc_test
//
//  Created by lingowu on 2022/4/7.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Person.h"
#import "XJPerson.h"
#import "SDSingleDog.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[SDSingleDog new] methodTest];
        
        /*
        XJPerson *person = [XJPerson alloc];
        Class pClass = person.class;
        [person smileToLife];
        [person loveEveryone];
        [person takeCareFamily];
        
        struct xj_objc_class *xj_class = (__bridge struct xj_objc_class *)(pClass);
        
        NSLog(@"occupied = %hu - mask = %u", xj_class->cache._occupied, xj_class->cache._maybeMask);
        
        for (mask_t i = 0; i < xj_class->cache._maybeMask; i++) {
            struct xj_bucket_t bucket = xj_class->cache._buckets[i];
            NSLog(@"%@ - %pf", NSStringFromSelector(bucket._sel), bucket._imp);
        }
        
        NSLog(@"Hello, World!");
        
        Person *p1 = [Person alloc];
        Person *p2 = [p1 init];
        Person *p3 = [p1 init];
        
        Person *p4 = [Person alloc];
        
        NSLog(@"%@-%p-%p", p1, p1, &p1);
        NSLog(@"%@-%p-%p", p2, p2, &p2);
        NSLog(@"%@-%p-%p", p3, p3, &p3);
        
        NSLog(@"%@-%p-%p", p4, p4, &p4);
        [[Person new] hello];
        [p4 hello];
        
        
        Class class1 = [Person class];
        Class class2 = [Person alloc].class;
        Class class3 = object_getClass([Person alloc]);
        Class class4 = [Person alloc].class;
        NSLog(@"\n%p-\n%p-\n%p-\n%p",class1,class2,class3,class4);
        
        
        NSObject *o = [NSObject alloc];
        NSLog(@"%lu - %lu",class_getInstanceSize([o class]), malloc_size((__bridge const void *)(o)));
        Person *p = [Person new];
        NSLog(@"%lu - %lu",class_getInstanceSize([p class]), malloc_size((__bridge const void *)(p)));
        
        Class cls = [Person class];
        NSLog(@"%p  %p", p, cls);
        [[Person new] hello];
        [[Person new] hello];
        [[Person new] hello];
        // [[Person new] show];
        NSLog(@"Hello, World!");*/
    }
    return 0;
}

void kindOfTest(void) {
    BOOL re1 = [(id)[NSObject class] isKindOfClass:[NSObject class]];
    BOOL re2 = [(id)[NSObject class] isMemberOfClass:[NSObject class]];
    BOOL re3 = [(id)[Person class] isKindOfClass:[Person class]];
    BOOL re4 = [(id)[Person class] isMemberOfClass:[Person class]];
    NSLog(@"re1 :%hhd re2 :%hhd re3 :%hhd re4 :%hhd", re1, re2, re3, re4);

    BOOL re5 = [(id)[NSObject alloc] isKindOfClass:[NSObject class]];
    BOOL re6 = [(id)[NSObject alloc] isMemberOfClass:[NSObject class]];
    BOOL re7 = [(id)[Person alloc] isKindOfClass:[Person class]];
    BOOL re8 = [(id)[Person alloc] isMemberOfClass:[Person class]];
    NSLog(@"re5 :%hhd re6 :%hhd re7 :%hhd re8 :%hhd", re5, re6, re7, re8);
}

extern size_t class_getInstanceSize(Class _Nullable cls);
extern size_t malloc_size(const void *ptr);

struct xj_bucket_t {
    SEL _sel;
    IMP _imp;
};

struct xj_class_data_bits_t {
    uintptr_t bits;
};

typedef uint32_t mask_t;
struct xj_cache_t {
    struct xj_bucket_t *_buckets;   // 8
    mask_t              _maybeMask; // 4
    uint16_t            _flags;     // 2
    uint16_t            _occupied;  // 2
};

struct xj_objc_class {
    Class isa;
    Class superclass;
    struct xj_cache_t cache;             // formerly cache pointer and vtable
    struct xj_class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
};
