//
//  AKPromptContentProtocol.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^AKPromptComplete) ();

@protocol AKPromptContentProtocol <NSObject>

@required

/**
 显示方法
 当视图将要显示的时候，AKPromptManager会调用此方法

 @param window 将要显示在的UIWindow
 @param complete 结束block
 */
- (void)appearInWindow:(UIWindow *)window complete:(AKPromptComplete)complete;

/**
 隐藏方法
 当视图将要隐藏的时候，AKPromptManager会调用此方法
 */
- (void)disappear;

@end
