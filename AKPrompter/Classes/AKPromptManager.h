//
//  AKPromptManager.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import "AKPromptProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKPromptManager : NSObject

/**
 弹窗
 当使用UIAlertController时，需要使用最佳实践，否则会出现视图层叠现象
 参考https://stackoverflow.com/questions/26554894/how-to-present-uialertcontroller-when-not-in-a-view-controller

 @param prompt id<AKPromptProtocol>
 */
+ (void)prompt:(id<AKPromptProtocol>)prompt;

/**
 取消弹窗
 如果当前弹窗为唯一的弹窗，且已经显示，则需要等弹窗操作完成之后才会被取消

 @param prompt id<AKPromptProtocol>
 */
+ (void)cancle:(id<AKPromptProtocol>)prompt;

@end

NS_ASSUME_NONNULL_END
