//
//  ViewController.m
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"
#import "student.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  /*
    ///  获的某个类的所有成员变量
    ///
    ///  参数1:要获取的类
    ///  参数2:成员变量的个数 (这里需要传一个`unsigned int`类型变量地址)
    ///
    ///  @return Ivar * (返回一个`Ivar *`类型的指针,里面装满了这个类的成员变量,类似一个数组,但不是数组)
    unsigned int outCount = 0;
    
    Ivar *ivars = class_copyIvarList([Person class], &outCount);
    //方法描述:可以这样来理解这个方,拷贝某个类`参数1`的成员变量列表,当这个方法执行完时,我们可以得到这个类的所有成员变量个数保存在`unsigned int`类型的变量`参数2`中.
    
    // 遍历所有成员变量
    for (int i = 0; i < outCount; i++) {
        // 逐个取出
        Ivar ivar = ivars[i];
        
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        
        NSLog(@"name:%s--type:%s--offset:%zd",name,type,offset);
    }
    
    free(ivars);
   
   */
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

//    Person *per = [[Person alloc] init];
//    per.name = @"jack";
//    per.age = 26;
//    per.heiget = 1.75;
//    per.weight = 56;
//    per.ignore1 = 1;
//    per.ignore2 = 2;
//    per.ignore3 = 3;
    
//       //  归档
//    [NSKeyedArchiver archiveRootObject:st toFile:@"/Users/azure/Desktop/person.plist"]

    
//        // 解档
//    Person *per = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/azure/Desktop/person.plist"];
    
//    NSLog(@"%@--%zd--%.2f--%.2lf,%zd--%zd--%zd",per.name,per.age,per.heiget,per.weight,per.ignore1,per.ignore2,per.ignore3);

    
//    ============================================================
    
    student *st = [[student alloc] init];
    st.studyNo = 7;
    st.name = @"andy";
    
    // 归档
    [NSKeyedArchiver archiveRootObject:st toFile:@"/Users/azure/Desktop/student.plist"];

//    // 解档
//    student *st = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/azure/Desktop/student.plist"];
//    NSLog(@"%zd,%@",st.studyNo,st.name);
    
}

@end
