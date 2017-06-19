//
//  AKPromptManager.m
//  Pods
//
//  Created by 李翔宇 on 2017/6/12.
//
//

#import "AKPromptManager.h"
#import "AKPrompterMacro.h"

@interface AKPromptManager ()

/**
 等待安排的Prompt。数组最后的是最新添加的
 */
@property (nonatomic, strong) NSMutableArray<id<AKPromptProtocol>> *waitingPromptsM;

/**
 顺序显示的Prompt。模仿系统
 */
@property (nonatomic, strong) NSMutableArray<id<AKPromptProtocol>> *queuePromptsM;

@property (nonatomic, strong) id<AKPromptProtocol> currentPrompt;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) UIWindow *window;

@end

@implementation AKPromptManager

__attribute__((constructor))
static void AKPromptManagerHook() {
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIApplicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopBeforeWaiting:
                [AKPromptManager.manager assignPromptWithMoment:AKPromptMomentFree];
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopDefaultMode);
}

#pragma mark - 标准单例
+ (AKPromptManager *)manager {
    static AKPromptManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        
        sharedInstance.waitingPromptsM = [NSMutableArray array];
        sharedInstance.queuePromptsM = [NSMutableArray array];
        
        sharedInstance.semaphore = dispatch_semaphore_create(1);
        
        NSString *label = [NSString stringWithFormat:@"%@.AKPromptManager.serialQueue", NSBundle.mainBundle.bundleIdentifier];
        sharedInstance.queue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL);
    });
    return sharedInstance;
}

+ (id)alloc {
    return [self manager];
}

+ (id)allocWithZone:(NSZone * _Nullable)zone {
    return [self manager];
}

- (id)copy {
    return self;
}

- (id)copyWithZone:(NSZone * _Nullable)zone {
    return self;
}

#pragma mark - Public Method
+ (void)prompt:(id<AKPromptProtocol>)prompt {
    if(!prompt) {
        AKPrompterLog(@"prompt不可为空");
        return;
    }
    
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    [self.manager.waitingPromptsM addObject:prompt];
    dispatch_semaphore_signal(self.manager.semaphore);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(prompt.moment == AKPromptMomentImmediate) {
            [self.manager assignPromptWithMoment:AKPromptMomentImmediate];
        }
    });
}

+ (void)cancle:(id<AKPromptProtocol>)prompt {
    if(!prompt) {
        AKPrompterLog(@"prompt不可为空");
        return;
    }
    
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    [self.manager.waitingPromptsM removeObject:prompt];
    [self.manager.queuePromptsM removeObject:prompt];
    dispatch_semaphore_signal(self.manager.semaphore);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(prompt.moment == AKPromptMomentImmediate) {
            [self.manager assignPromptWithMoment:AKPromptMomentImmediate];
        }
    });
}

#pragma mark - Private Method
- (void)assignPromptWithMoment:(AKPromptMoment)moment {
    NSArray<id<AKPromptProtocol>> *waitingPrompts = [self.waitingPromptsM copy];
    for(id<AKPromptProtocol> prompt in waitingPrompts) {
        if(prompt.moment == AKPromptMomentImmediate
           || prompt.moment & moment) {
            [self.waitingPromptsM removeObject:prompt];
            
            NSMutableArray<id<AKPromptProtocol>> *promptsM = self.queuePromptsM;
            
            if(!promptsM.count) {
                [promptsM addObject:prompt];
                continue;
            }
            
            //总是插入相同优先级之前，模仿系统
            for(NSInteger i = 0; i < promptsM.count; i++) {
                id<AKPromptProtocol> _prompt = promptsM[i];
                if(prompt.priority >= _prompt.priority) {
                    [promptsM insertObject:prompt atIndex:i];
                    break;
                }
            }
            
            if(![promptsM containsObject:prompt]) {
                [promptsM addObject:prompt];
            }
        }
    }
    
    [self promptNext];
}

- (void)promptNext {
    NSArray<id<AKPromptProtocol>> *queuePrompts = [self.queuePromptsM copy];
    
    //如果没有可以显示的prompt，则替换UIWindow
    if(!queuePrompts.count) {
        //已经展示的prompt需要执行完
        if(!self.currentPrompt) {
            if(!UIApplication.sharedApplication.delegate.window.isKeyWindow) {
                [UIApplication.sharedApplication.delegate.window makeKeyAndVisible];
            }
        }
        return;
    }
    
    if(self.currentPrompt == queuePrompts.firstObject) {
        return;
    }
    
    [self.currentPrompt.content disappear];
    self.currentPrompt = queuePrompts.firstObject;
    
    if([self.currentPrompt.content isKindOfClass:[UIViewController class]]) {
        self.window.rootViewController = (UIViewController *)self.currentPrompt.content;
    } else if([self.currentPrompt.content isKindOfClass:[UIView class]]) {
        self.window.rootViewController = [[UIViewController alloc] init];
        [self.window.rootViewController.view addSubview:(UIView *)self.currentPrompt.content];
    } else {
        self.window.rootViewController = [[UIViewController alloc] init];
    }
    
    if(!self.window.isKeyWindow) {
        [self.window makeKeyAndVisible];
    }
    
    __weak typeof(self) weak_self = self;
    [self.currentPrompt.content appearInWindow:self.window complete:^{
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self.queuePromptsM removeObject:strong_self.currentPrompt];
        strong_self.currentPrompt = nil;
        [strong_self promptNext];
    }];
}

#pragma mark - NSNotification
- (void)onUIApplicationDidFinishLaunchingNotification:(NSNotification *)notification {
    AKPrompterLog(@"UIApplicationDidFinishLaunchingNotification");
    [self assignPromptWithMoment:AKPromptMomentLaunchFinish];
}

- (void)onUIApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    AKPrompterLog(@"UIApplicationDidBecomeActiveNotification");
    [self assignPromptWithMoment:AKPromptMomentBecomeActive];
}

#pragma mark - Property Method

- (UIWindow *)window {
    if(_window) {
        return _window;
    }
    
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.3];
    return _window;
}

@end
