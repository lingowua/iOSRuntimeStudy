//
//  main.m
//  objc_test
//
//  Created by lingowu on 2022/4/7.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Person.h"

extern size_t class_getInstanceSize(Class _Nullable cls);
extern size_t malloc_size(const void *ptr);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
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
        NSLog(@"Hello, World!");
    }
    return 0;
}
