//
//  NSObject+Extension.h
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

- (void)setDict:(NSDictionary *)dict;

+ (instancetype)objectWithDict:(NSDictionary *)dict;

@end
