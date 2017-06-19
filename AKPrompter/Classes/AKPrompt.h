//
//  AKPrompt.h
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#import <Foundation/Foundation.h>
#import "AKPromptProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKPrompt : NSObject<AKPromptProtocol>

@property (nonatomic, strong) id<AKPromptContentProtocol> content;

@property (nonatomic, assign) AKPromptMoment moment;
@property (nonatomic, assign) AKPromptPriority priority;

@end

NS_ASSUME_NONNULL_END
