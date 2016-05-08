//
//  ViewController.m
//  runtime（方法交换演练）
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIImage+Extension.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageView1.image = [UIImage imageNamed:@"stop"];
    self.imageView2.image = [UIImage imageNamed:@"start"];
    


}



@end
