//
//  AKTestController.m
//  AKPrompter
//
//  Created by 李翔宇 on 2017/6/28.
//  Copyright © 2017年 Freud. All rights reserved.
//

#import "AKTestController.h"
#import <Masonry/Masonry.h>

@interface AKTestController ()

@property (nonatomic, strong) AKPromptComplete complete;

@end

@implementation AKTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor.redColor colorWithAlphaComponent:.3];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = UIScreen.mainScreen.bounds;
    [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 显示方法
 当视图将要显示的时候，AKPromptManager会调用此方法
 
 @param window 将要显示在的UIWindow
 @param complete 结束block
 */
- (void)appearInWindow:(UIWindow *)window complete:(AKPromptComplete)complete {
    self.complete = complete;
}

/**
 隐藏方法
 当视图将要隐藏的时候，AKPromptManager会调用此方法
 */
- (void)disappear {
    //self.frame = CGRectZero;
}

- (void)buttonTouchUpInside:(UIButton *)button {
    self.complete();
}

@end
