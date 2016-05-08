//
//  Dog.h
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bone.h"

@interface Dog : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) int leg;

@property (nonatomic,strong) Bone *bone;

@end
