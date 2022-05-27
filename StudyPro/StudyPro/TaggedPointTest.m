//
//  TaggedPointTest.m
//  StudyPro
//
//  Created by lingowu on 2022/4/14.
//

#import "TaggedPointTest.h"

extern uintptr_t objc_debug_taggedpointer_obfuscator;
#define DTag(num) ((uintptr_t)num ^ objc_debug_taggedpointer_obfuscator)

@implementation TaggedPointTest


// 去掉最高位和最低的4 bit
#define MASK        0x0ffffffffffffff0ULL
#define TAG_MASK    (1UL <<63)
const NSString *rcx = @"eilotrm.apdnsIc ufkMShjTRxgC4013bDNvwyUL2O856P-B79AFKEWV_zGJ/HYX";

- (void)decodeTaggedPointer:(NSString *)str {
    printf("原字符串: %s\n", [str UTF8String]);
    uintptr_t p = DTag(str);
    if ((p & TAG_MASK) != TAG_MASK) {
        printf("当前字符串不属于 Tagged Pointer 地址为： %lx \n\n", p);
        return;
    }
    
    printf("解码前： %lx \n解码后： ", p);
    // 将最低位的记录字符串个数的数字移除
    uintptr_t num = (p & MASK) >> 4;
    int mask = 0x1f, bit = 5;
    if (7 >= [str length]) {
        mask = 0xff;
        bit = 8;
    } else if (9 >= [str length]) {
        mask = 0x3f;
        bit = 6;
    }
    
    while (num) {
        int idx = num & mask;
        printf("%c", bit == 8 ? idx : [rcx characterAtIndex:idx]);
        num = num >> bit;
    }
    printf("\n\n");
}


- (void)show {
    NSNumber *n1 = @1, *n2 = @2, *n3 = @3, *n4 = @(0xFFFF), *n5 = @(0xEFFFFFFFFFFFFFFF);
    printf("%p %p %p %p\n%p\n\n", n1, n2, n3, n4, n5);
    printf("%lx %lx %lx %lx\n%lx\n\n", DTag(n1), DTag(n2), DTag(n3), DTag(n4), DTag(n5));
    
    char a = 1;
    short b = 1;
    int c = 1;
    long d = 1;
    float e = 1.0;
    double f = 1.00;
    NSNumber *nu1 = @(a), *nu2 = @(b), *nu3 = @(c), *nu4 = @(d), *nu5 = @(e), *nu6 = @(f);
    printf("%lx %lx %lx %lx\n%lx %lx\n\n", DTag(nu1), DTag(nu2), DTag(nu3), DTag(nu4), DTag(nu5), DTag(nu6));
    
    NSString *s1 = [NSString stringWithFormat:@"a"];
    NSString *s2 = [NSString stringWithFormat:@"ab"];
    NSString *s3 = [NSString stringWithFormat:@"abc"];
    NSString *s4 = [NSString stringWithFormat:@"abcd"];
    NSString *s5 = [NSString stringWithFormat:@"abcde"];
    NSString *s6 = [NSString stringWithFormat:@"abcdef"];
    NSString *s7 = [NSString stringWithFormat:@"abcdefg"];
    NSString *s8 = [NSString stringWithFormat:@"m.apdnsIc u"];
    NSString *s9 = [NSString stringWithFormat:@"cdefghijklm"];
    NSString *s10 = [NSString stringWithFormat:@"abcdefghij"];
    printf("%lx %lx %lx %lx\n", DTag(s1), DTag(s2), DTag(s3), DTag(s4));
    printf("%lx %lx %lx %lx\n", DTag(s5), DTag(s6), DTag(s7), DTag(s8));
    printf("%lx %lx\n", DTag(s9), DTag(s10));
    [self decodeTaggedPointer:s8];
    [self decodeTaggedPointer:s2];
    [self decodeTaggedPointer:s3];
    [self decodeTaggedPointer:s4];
    [self decodeTaggedPointer:s5];
    [self decodeTaggedPointer:s6];
    [self decodeTaggedPointer:s7];
    [self decodeTaggedPointer:s8];
    [self decodeTaggedPointer:s9];
    [self decodeTaggedPointer:s10];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"abcdefghi"];
        });
    }
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            @synchronized (self) {
                self.name = [NSString stringWithFormat:@"abcdefghij"];
            }
        });
    }
}

@end
