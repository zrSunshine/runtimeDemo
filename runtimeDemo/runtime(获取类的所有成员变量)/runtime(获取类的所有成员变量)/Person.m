//
//  Person.m
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

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
        
        // ivar_getName(ivar)返回一个C语言的 `const char *`类型,我们需要转换成OC的字符串来进行归档
        // C语言字符串转换成OC字符串
        // @(ivar_getName(ivar)) 等价于 [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];

        // 利用KVC获取对应成员变量的值
        id value = [self valueForKeyPath:key];
        
        // 根据key和value进行归档
        [encoder encodeObject:value forKey:key];
    }
    // 释放资源
    free(ivars);
}





@end
