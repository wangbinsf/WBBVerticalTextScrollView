//
//  ViewController.m
//  WBBVerticalScroll
//
//  Created by 王宾宾 on 16/8/12.
//  Copyright © 2016年 王宾宾. All rights reserved.
//

#import "ViewController.h"
#import "WBBVerticalTextScrollView.h"
@interface ViewController ()

@end

@implementation ViewController
/**
 *  viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    WBBVerticalTextScrollView *sc = [[WBBVerticalTextScrollView alloc]init];
    sc.frame = CGRectMake(20, 120, 200, 30);
    sc.items = @[@"管家帮头条",@"李连杰付出打败泰森",@"周火箭或或佳话"];
    [self.view addSubview:sc];
}

//一值在测试

@end
