//
//  student.h
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "Person.h"


@interface student : Person <NSCoding>

@property (nonatomic, assign) int studyNo;

@end
