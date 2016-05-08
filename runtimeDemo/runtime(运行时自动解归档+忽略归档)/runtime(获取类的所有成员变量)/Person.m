//
//  Person.m
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>
#import "NSObject+Extension.h"
#import "Coding.h"

@implementation Person

///  不需要归档的属性
- (NSArray *)ignoreNames {

    return @[@"_ignore1",@"_ignore2",@"_ignore3"];
}

// 实现归档解档
CodeingImple

/*

///  从文件中读取 (解档)
- (instancetype)initWithCoder:(NSCoder *)decoder {

    if (self = [super init]) {
        
        unsigned int outCount = 0;
        // 获取类的所有成员变量
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        // 逐个获取
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            
            // C语言字符串转换成OC字符串
            NSString *key = @(ivar_getName(ivar));
            
            // 忽略不需要解档的属性
            if ([[self ignoreNames] containsObject:key]) continue;
            
            // 解档
            id value = [decoder decodeObjectForKey:key];
            
            // 这句代码就等于(decoder decode...ForKey:),给每个属性设置value
            [self setValue:value forKeyPath:key];
        }
        // 释放
        free(ivars);
    }
    return self;
}


///  保存到文件中 (归档)
- (void)encodeWithCoder:(NSCoder *)encoder {
    
    unsigned int outCount = 0;
    // 获取类的所有成员变量
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    // 逐个获取
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        
        // C语言字符串转换成OC字符串
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 忽略不需要归档的属性
        if ([[self ignoreNames] containsObject:key]) continue;

        // 利用KVC获取对应成员变量的值
        id value = [self valueForKeyPath:key];
        
        // 根据key和value进行归档
        [encoder encodeObject:value forKey:key];
    }
    // 释放资源
    free(ivars);
}

*/

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super init]) {
//        
//        [self decode:aDecoder];
//    }
//    return self;
//}
//
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    
//    [self encode:aCoder];
//}



@end
