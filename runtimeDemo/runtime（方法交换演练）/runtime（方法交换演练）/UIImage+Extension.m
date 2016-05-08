//
//  UIImage+Extension.m
//  runtime（方法交换演练）
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "UIImage+Extension.h"
#import <objc/runtime.h>

@implementation UIImage (Extension)


+ (void)load {

    // 获得需要交换的两个方法
    Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
    Method m2 = class_getClassMethod([UIImage class], @selector(px_imageName:));
    
    // 交换方法的实现
    method_exchangeImplementations(m1, m2);
    
    
}





+ (UIImage *)px_imageName:(NSString *)imageName {

    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0) {
        imageName = [imageName stringByAppendingString:@"_os7"];
    }
    
    // 调回系统的方法
    // 这里需要调用系统方法来赋值，我们就应该调用自己的方法交换到系统的方法
    return [UIImage px_imageName:imageName];
}

@end
