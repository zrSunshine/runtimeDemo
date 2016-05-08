//
//  NSObject+Extension.m
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject (Extension)



///  从文件中读取 (解档)
- (void)decode:(NSCoder *)decoder {
    
    
    Class currentClass = self.class;
    // 如果当前类不是NSObject这个类,就实现归档
    while (currentClass && currentClass != [NSObject class]) {
    
        unsigned int outCount = 0;
        // 获取类的所有成员变量
        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
        // 逐个获取
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            
            // C语言字符串转换成OC字符串
            NSString *key = @(ivar_getName(ivar));
            
            // 判断调用的类中是否有要忽略的属性
            if ([self respondsToSelector:@selector(ignoreNames)]) {
                // 忽略不需要解档的属性
                if ([[self ignoreNames] containsObject:key]) continue;
            }
            
            // 解档
            id value = [decoder decodeObjectForKey:key];
            
            // 这句代码就等于(decoder decode...ForKey:),给每个属性设置value
            [self setValue:value forKeyPath:key];
        }
        // 释放
        free(ivars);
        // 重新赋值当前的类
        currentClass = [currentClass superclass];
    }
}


///  保存到文件中 (归档)
- (void)encode:(NSCoder *)encoder {
    
    Class currentClass = self.class;
    // 如果当前类不是NSObject这个类,就实现归档
    while (currentClass && currentClass != [NSObject class]) {
    
        unsigned int outCount = 0;
        // 获取类的所有成员变量
        Ivar *ivars = class_copyIvarList(currentClass, &outCount);
        // 逐个获取
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            
            // C语言字符串转换成OC字符串
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            // 判断调用的类中是否有要忽略的属性
            if ([self respondsToSelector:@selector(ignoreNames)]) {
                // 忽略不需要解档的属性
                if ([[self ignoreNames] containsObject:key]) continue;
            }
            
            // 利用KVC获取对应成员变量的值
            id value = [self valueForKeyPath:key];
            
            // 根据key和value进行归档
            [encoder encodeObject:value forKey:key];
        }
        // 释放资源
        free(ivars);
        // 重新赋值当前的类
        currentClass = [currentClass superclass];
    }
}


@end
