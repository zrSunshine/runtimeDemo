//
//  Person.h
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) CGFloat heiget;
@property (nonatomic,assign) double weight;
@property (nonatomic,assign) int age;


@end
