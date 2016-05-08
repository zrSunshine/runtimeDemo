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
#import "Book.h"


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
                           },
                           @"books" : @[
                                   @{
                                       @"name" : @"goodBook",
                                       @"color" : @"yellow",
                                       @"price" : @10
                                       },
                                   @{
                                       @"name" : @"badBook",
                                       @"color" : @"red",
                                       @"price" : @20
                                       }
                                   ],
                           @"money" : @10 // 酱油属性,测试是否crash
                           };
    

    Person *per = [Person objectWithDict:dict];

    for (Book *book in per.books) {
        
        NSLog(@"%@--%@--%zd",book.name,book.color,book.price);
    }
    


    
    




    
   
    
//    NSLog(@"%@--%lf--%lf--%zd",per.name,per.height,per.weight,per.age);
//    NSLog(@"%@--%zd",per.dog.name,per.dog.leg);
//    NSLog(@"%@--%.2lf",per.dog.bone.name,per.dog.bone.weight);
    
}



@end
