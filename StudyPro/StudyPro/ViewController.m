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
#import "TaggedPointTest.h"

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
    
    // [self addressTest];
    // [self tagpointerTest];
    // [self addMethodTest];
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

- (void)addressTest {
    NSString *tt = @"teste", *tt1 = @"teasdtesdt";
    
    id cls = [Person class];
    void *obj = &cls;
    [(__bridge id)obj show];
    
    NSLog(@"ViewController = %@ , 地址 = %p", self, &self);
    NSLog(@"Person class = %@ 地址 = %p", cls, &cls);
    NSLog(@"Void *obj = %@ 地址 = %p", obj, &obj);
    
    Person *p = [Person new];
    NSObject *n = [NSObject new];
    [p show];
    NSLog(@"Person instance = %@ 地址 = %p", p, &p);
    
    BOOL res1 = [[NSObject class] isKindOfClass:[NSObject class]];
    BOOL res2 = [[NSObject class] isMemberOfClass:[NSObject class]];
    BOOL res3 = [[Person class] isKindOfClass:[Person class]];
    BOOL res4 = [[Person class] isMemberOfClass:[Person class]];
    BOOL res5 = [n isKindOfClass:[NSObject class]];
    BOOL res6 = [n isMemberOfClass:[NSObject class]];
    BOOL res7 = [p isKindOfClass:[Person class]];
    BOOL res8 = [p isMemberOfClass:[Person class]];

    NSLog(@"%d %d %d %d", res1, res2, res3, res4);
    NSLog(@"%d %d %d %d", res5, res6, res7, res8);
}

- (void)tagpointerTest {
    TaggedPointTest *tagTest = [TaggedPointTest new];
    [tagTest show];
}

- (void)addMethodTest {
    Person *p = [Person new];
    p.name1 = @"teast";
    NSLog(@"%@", p.name1);
    objc_removeAssociatedObjects(p);
    NSLog(@"%@", p.name1);
    if ([p respondsToSelector:@selector(eat)]) {
        [p performSelector:@selector(eat)];
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
    p.name1 = @"test";
    
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
    
    objc_property_t *pros = class_copyPropertyList([Person class], &outCount);

    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_t o_t =  pros[i];
        NSString *name = @(property_getName(o_t));
        NSString *attributes = @(property_getAttributes(o_t));
        NSLog(@"属性  %@  \t%@", name, attributes);
    }
    free(pros);
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
