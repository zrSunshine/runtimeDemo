//
//  NSObject+Name.m
//  runtime（关联对象）
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "NSObject+Name.h"
#import <objc/runtime.h>

@implementation NSObject (Name)

char nameKey;

- (void)setName:(NSString *)name {
    
    ///  设置关联对象
    ///
    ///  @param object#> 哪个对象需要存储值  一般是self
    ///  @param key#>    根据这个key关联对象，(void *类型)建议使用char
    ///  @param value#>  需要关联的值
    ///  @param policy#> 存储策略
    objc_setAssociatedObject(self, &nameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSString *)name {
    
    // 获取关联对象的值
    return objc_getAssociatedObject(self, &nameKey);

}



@end
