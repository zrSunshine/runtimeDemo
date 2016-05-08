//
//  Book.h
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/30.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Book : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,assign) int price;

@end
