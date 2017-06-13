//
//  AKTestView.h
//  AKPrompter
//
//  Created by 李翔宇 on 2017/6/13.
//  Copyright © 2017年 Freud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKPromptContentProtocol.h"

@interface AKTestView : UIView<AKPromptContentProtocol>

- (instancetype)initWithColor:(UIColor *)color targetFrame:(CGRect)frame;

@end
