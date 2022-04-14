//
//  ViewController.m
//  StudyPro
//
//  Created by lingowu on 2022/3/31.
//

#import <objc/runtime.h>
#import "ViewController.h"
#import "Person.h"
#import "Student.h"
#import "Dog.h"
#import "StudyProConst.h"

//#define ISA_MASK        0x007ffffffffffff8ULL
//#define ISA_MASK        0x0000000ffffffff8ULL
//#define ISA_MASK        0x00007ffffffffff8ULL
size_t malloc_size(const void *ptr);

extern uintptr_t objc_debug_taggedpointer_obfuscator;
#define DTag(num) ((uintptr_t)num ^ objc_debug_taggedpointer_obfuscator)

#define HTLog(_var) \
{ \
    NSString *name = @#_var; \
    NSLog(@"%@: %p, %@", name, _var, [_var class]); \
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tagpointerTest];
    // [self categoryMethodTest];
    // [self cxx_destructTest];
    // [self methodSwizzeTest];
    // [self categoryTest];
    // [self showIvars];
    // [self showClass];
    // [self classLifeCycle];
    // [self getClassList];
    // [self copyClassList];
}

- (void)tagpointerTest {
    NSNumber *nu1 = @1, *nu2 = @2, *nu3 = @3, *nu4 = @(0xFFFF), *nu5 = @(0xEFFFFFFFFFFFFFFF);
    // NSLog(@"解密前： %p %p %p %p %p", nu1, nu2, nu3, nu4, nu5);
    NSLog(@"Number1: %lx %lx %lx %lx %lx", DTag(nu1), DTag(nu2), DTag(nu3), DTag(nu4), DTag(nu5));
    
    char a = 1;
    short b = 1;
    int c = 1;
    long d = 1;
    float e = 1.0;
    double f = 1.00;
    
    NSNumber *n1 = @(a), *n2 = @(b), *n3 = @(c), *n4 = @(d), *n5 = @(e), *n6 = @(f);
    // NSLog(@"%p %p %p %p %p %p", n1, n2, n3, n4, n5, n6);
    NSLog(@"Number2: %lx %lx %lx %lx %lx %lx", DTag(n1), DTag(n2), DTag(n3), DTag(n4), DTag(n5), DTag(n6));
    
    NSString *s1 = [NSString stringWithFormat:@"a"];
    NSString *s2 = [NSString stringWithFormat:@"ab"];
    NSString *s3 = [NSString stringWithFormat:@"abc"];
    NSString *s4 = [NSString stringWithFormat:@"abcd"];
    NSString *s5 = [NSString stringWithFormat:@"lllllllll"];
    NSString *s6 = [NSString stringWithFormat:@"abcdefghij"];
    NSString *s7 = [NSString stringWithFormat:@"cdefghijkl"];
    NSString *s8 = [NSString stringWithFormat:@"cdefghijklm"];
    NSString *s9 = [NSString stringWithFormat:@"cdefghijklmn"];
    printf("\n\n%p %p %p %p\n%p %p %p %p\n%p\n\n\n", s1, s2, s3, s4, s5, s6, s7, s8, s9);
    NSLog(@"String: %p %p %p %p %p %p %p", s1, s2, s3, s4, s5, s6, s7);
    NSLog(@"String: %lx %lx %lx %lx %lx %lx", DTag(s1), DTag(s2), DTag(s3), DTag(s4), DTag(s5), DTag(s6));
    
    Person *pp = [Person new];
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            pp.name = [NSString stringWithFormat:@"abcdefghi"];
        });
    }
}

- (void)categoryMethodTest {
    Person *p = [Person new];
    p.name = @"fadsf";
    [p show];
    [self categoryMethodTest:p andName:@"setName:" andPara:@"test"];
    [self categoryMethodTest:p andName:@"show" andPara:nil];
    
    Dog *d = [Dog new];
    printf("call dog bark:  ");
    [d bark];
    [self categoryMethodTest:d andName:@"bark" andPara:nil];
    printf("call dog eat:  ");
    [d eat];
    [self categoryMethodTest:d andName:@"eat" andPara:nil];
    printf("call dog run:  ");
    [d run];
    [self categoryMethodTest:d andName:@"run" andPara:nil];
    printf("call dog sleep:  ");
    [d sleep];
    [self categoryMethodTest:d andName:@"sleep" andPara:nil];
}

- (void)categoryMethodTest:(id)target andName:(NSString *)methodName andPara:(NSString *)para {
    Class currentClass = [target class];

    if (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        IMP lastImp = NULL;
        SEL lastSel = NULL;
        for (NSInteger i = 0; i < methodCount; i++) {
            Method method = methodList[i];
            NSString *curMethodName = [NSString stringWithCString:sel_getName(method_getName(method))
                                            encoding:NSUTF8StringEncoding];
            if ([methodName isEqualToString:curMethodName]) {
                lastImp = method_getImplementation(method);
                lastSel = method_getName(method);
            }
        }
        
        if (lastImp != NULL) {
            if (para == NULL) {
                typedef void (*fn)(id,SEL);
                fn f = (fn)lastImp;
                f(target, lastSel);
            } else {
                typedef void (*fn)(id, SEL, NSString *);
                fn f = (fn)lastImp;
                f(target, lastSel, para);
            }
        }
        
        free(methodList);
    }
}

- (void)cxx_destructTest {
    MyObj *myObject = [[MyObj alloc] init];
    myObject.age = 18;
    myObject.name = @"tets";
    NSLog(@"myObject.name=%@,myObject.age=%ld",myObject.name, myObject.age);
}

- (void)methodSwizzeTest {
    Dog *d = [Dog new];
    printf("call dog bark:  ");
    [d bark];
    printf("call dog eat:  ");
    [d eat];
    printf("call dog run:  ");
    [d run];
    printf("call dog sleep:  ");
    [d sleep];
}

- (void)categoryTest {
    Person *p = [Person new];
    p.name = @"tete";
    p.name1 = @"haha";
    [p show];
    [Person load];
}

- (void)showIvars {
    Person *p = [Person new];
    p.name = @"test";
    
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([Person class], &outCount);
    
    Ivar ivar = ivars[0];
    const char *ivarName = ivar_getName(ivar);
    const char *ivarType = ivar_getTypeEncoding(ivar);
    NSLog(@"实例变量内容设置前 是：%@", object_getIvar(p, ivar));
    object_setIvar(p, ivar, @"objc_test");
    NSLog(@"实例变量内容设置后是：%@", object_getIvar(p, ivar));
    NSLog(@"实例变量名为：%s 字符串类型为：%s", ivarName, ivarType);
    
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        const char *ivarName = ivar_getName(ivar);
        const char *ivarType = ivar_getTypeEncoding(ivar);
        NSLog(@"实例变量名为：%s 字符串类型为：%s", ivarName, ivarType);
    }
    free(ivars);
}

- (void)showClass {
    const char* name = class_getName([Person class]);
    NSLog(@"name = %s", name);

    // Person* person = [Person new];
    Class class = objc_getMetaClass(name);
    NSLog(@"class = %@",class);
    
    const char* name_notexist = "Person1";
    
    Class class1 = objc_getClass(name);
    NSLog(@"class1 = %@",class1);
    Class class1_notexist = objc_getClass(name_notexist);
    NSLog(@"class1_notexist = %@",class1_notexist);
    
    Class class2 = objc_lookUpClass(name);
    NSLog(@"class2 = %@",class2);
    Class class2_notexist = objc_lookUpClass(name_notexist);
    NSLog(@"class2_notexist = %@",class2_notexist);
    
    Class class3 = objc_getRequiredClass(name);
    NSLog(@"class3 = %@",class3);
    // Class class3_notexist = objc_getRequiredClass(name_notexist);
    // NSLog(@"class3_notexist = %@",class3_notexist);
    
    BOOL isMetaClass1 = class_isMetaClass(class);
    BOOL isMetaClass2 = class_isMetaClass(class1);
    NSLog(@"objc_getMetaClass = %d,objc_getClass = %d",isMetaClass1, isMetaClass2);
}

-(void)classLifeCycle {
    Class class = objc_allocateClassPair(objc_getClass("Person"), "Teacher" , 0);
    const char* name = class_getName(class);
    Class allocateClass = objc_getClass(name);
    NSLog(@"allocateClass = %@", allocateClass);
    
    objc_registerClassPair(class);
    Class registerClass = objc_getClass(name);
    NSLog(@"registerClass = %@", registerClass);
    
    // id tea = [registerClass new];
    
    objc_disposeClassPair(class);
    Class disposeClass = objc_getClass(name);
    NSLog(@"disposeClass = %@", disposeClass);
}

-(void)getClassList {
    int bufferCount = 4;
    Class* buffer = (Class*)malloc(sizeof(Class)* bufferCount);
    int count1 = objc_getClassList(buffer, bufferCount);
    for (unsigned int i =0; i <bufferCount; i++) {
        NSLog(@"name = %s",class_getName(buffer[i]));
    }
    NSLog(@"count1 = %d",count1);

    int count2 = objc_getClassList(NULL, 0);
    NSLog(@"count2 = %d",count2);
}


-(void)copyClassList {
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
    NSLog(@"outCount = %d",outCount);
    for (int i = 0; i < outCount; i++) {
        NSLog(@"%s", class_getName(classes[i]));
    }
    free(classes);
}

@end
