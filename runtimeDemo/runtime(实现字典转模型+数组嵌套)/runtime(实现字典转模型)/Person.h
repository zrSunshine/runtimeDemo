//
//  Person.h
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

@interface Person : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) double height;
@property (nonatomic,assign) double weight;
@property (nonatomic,assign) int age;
///  狗模型
@property (nonatomic,strong) Dog *dog;
///  书数组
@property (nonatomic,strong) NSArray *books;



@end
