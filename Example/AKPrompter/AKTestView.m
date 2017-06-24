//
//  AKTestView.m
//  AKPrompter
//
//  Created by 李翔宇 on 2017/6/13.
//  Copyright © 2017年 Freud. All rights reserved.
//

#import "AKTestView.h"
#import <AKPrompter/AKPromptContentProtocol.h>

@interface AKTestView ()

@property (nonatomic, assign) CGRect targetFrame;
@property (nonatomic, strong) AKPromptComplete complete;

@end

@implementation AKTestView

- (instancetype)initWithColor:(UIColor *)color targetFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if(self) {
        self.backgroundColor = [color colorWithAlphaComponent:.3];
        
        self.targetFrame = frame;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = UIScreen.mainScreen.bounds;
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

/**
 显示方法
 当视图将要显示的时候，AKPromptManager会调用此方法
 
 @param window 将要显示在的UIWindow
 @param complete 结束block
 */
- (void)appearInWindow:(UIWindow *)window complete:(AKPromptComplete)complete {
    self.hidden = NO;
    self.complete = complete;
    
    [UIView animateWithDuration:.35 animations:^{
        self.frame = self.targetFrame;
    }];
}

/**
 隐藏方法
 当视图将要隐藏的时候，AKPromptManager会调用此方法
 */
- (void)disappear {
    self.frame = CGRectZero;
}

- (void)buttonTouchUpInside:(UIButton *)button {
    self.complete();
}

@end
