//
//  ViewController.m
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import "NSObject+Extension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = @{
                           @"name" : @"andy",
                           @"height" : @1.70,
                           @"weight" : @50,
                           @"age" : @20,
                           @"dog" : @{
                               @"name" : @"wangcai",
                               @"leg" : @4,
                               @"bone" : @{
                                   @"name" : @"大骨头",
                                   @"weight" : @200
                               },
                           },
                           @"money" : @10 // 酱油属性,测试是否crash
                           };
    

    Person *per = [Person objectWithDict:dict];
    
    NSLog(@"%@--%lf--%lf--%zd",per.name,per.height,per.weight,per.age);
    NSLog(@"%@--%zd",per.dog.name,per.dog.leg);
    NSLog(@"%@--%.2lf",per.dog.bone.name,per.dog.bone.weight);
    
}



@end
