//
//  NSObject+Extension.h
//  runtime(获取类的所有成员变量)
//
//  Created by Azure on 16/4/27.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)
///  忽略方法
- (NSArray *)ignoreNames;
///  归档方法
- (void)encode:(NSCoder *)encoder;
///  解档方法
- (void)decode:(NSCoder *)decoder;

@end
