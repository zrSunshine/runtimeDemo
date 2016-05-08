//
//  NSObject+Extension.m
//  runtime(实现字典转模型)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>
#import "Person.h"
#import "Book.h"

@implementation NSObject (Extension)




- (void)setDict:(NSDictionary *)dict {

    Class currentClass = self.class;

    while (currentClass && currentClass != [NSObject class]) {
        
        unsigned int outCount = 0;
        // 获取类的所有成员变量
        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
        // 逐个获取
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            
            // 获得类的所有属性
            NSString *key = @(ivar_getName(ivar));
            key = [key substringFromIndex:1];
            // 取出字典
            id value = dict[key];
            // 如果字典中没有对应属性的值
            if (value == nil) continue;
            
            // 获取当前属性的类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
           

            // 查询类型中是否有"@"
            NSRange range = [type rangeOfString:@"@"];
            
            if (range.location != NSNotFound) {  // 能找到"@"
                type = [type substringWithRange:NSMakeRange(2, type.length - 3)];

                if (![type hasPrefix:@"NS"]) {
                   Class class = NSClassFromString(type);
                    value = [class objectWithDict:value];

                } else {
                    
                    Class class = NSClassFromString(type);
                    if ([class isSubclassOfClass:[NSArray class]]) {
                        
                        // 获得数组
                        NSArray *array = (NSArray *)value;
                        
                        NSMutableArray *arrayM = [NSMutableArray array];
                        
                        // 数组里面装的都是Book类型的字典
                        for (NSDictionary *dict in array) {
                         
                            // 将字典转模型
                            Book *book = [Book objectWithDict:dict];
                            
                            [arrayM addObject:book];
                        }
                        
                        value = arrayM;
                    }
                }
            }

            [self setValue:value forKeyPath:key];
        }
        // 释放
        free(ivars);
        // 重新赋值当前的类
        currentClass = [currentClass superclass];
    }
}

// 提供一个类方法,方便调用
+ (instancetype)objectWithDict:(NSDictionary *)dict {
    
    // 创建模型对象
    NSObject *objc = [[self alloc] init];
    
    [objc setDict:dict];
    
    return objc;
}


@end
