//
//  ViewController.m
//  runtime（关联对象）
//
//  Created by Azure on 16/4/26.
//  Copyright © 2016年 Azure. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Name.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    NSString *str = [NSString string];
    str.name = @"字符串";
    
    NSArray *array = [NSArray array];
    array.name = @"数组";
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.name = @"tableView";
    
    NSLog(@"%@--%@--%@",str.name,array.name,tableView.name);
}



@end
