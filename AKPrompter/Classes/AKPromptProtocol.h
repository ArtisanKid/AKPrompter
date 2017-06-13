//
//  AKPromptProtocol.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import "AKPromptContentProtocol.h"

//显示时机
typedef NS_OPTIONS (NSUInteger, AKPromptMoment) {
    AKPromptMomentImmediate = 0, //直接显示
    
    AKPromptMomentLaunchFinish = 1 << 0, //启动
    AKPromptMomentBecomeActive = 1 << 1, //活跃
    AKPromptMomentFree = 1 << 2, //空闲
};

//显示优先级
typedef NS_ENUM (NSUInteger, AKPromptPriority) {
    AKPromptPriorityLow = 0, //低
    AKPromptPriorityDefault, //默认
    AKPromptPriorityHigh, //高
    AKPromptPriorityRequired, //最高
};

@protocol AKPromptProtocol <NSObject>

/**
 content为UIViewController会自动设置为UIWindow的rootViewController，然后调用协议方法
 content为UIView会自动添加到UIWindow的rootViewController中，然后调用协议方法
 content为其他类型时，直接调用协议方法
 */
@property (nonatomic, strong, readonly) id<AKPromptContentProtocol> content;

@property (nonatomic, assign, readonly) AKPromptMoment moment;
@property (nonatomic, assign, readonly) AKPromptPriority priority;

@end
