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

@property (atomic, assign, getter=isOtherWindowVisible) BOOL otherWindowVisible;
@property (nonatomic, strong) UIWindow *window;

@end

@implementation AKPromptManager

__attribute__((constructor))
static void AKPromptManagerHook() {
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIWindowDidBecomeVisibleNotification:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIWindowDidBecomeHiddenNotification:) name:UIWindowDidBecomeHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIWindowDidBecomeKeyNotification:) name:UIWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:AKPromptManager.manager selector:@selector(onUIWindowDidResignKeyNotification:) name:UIWindowDidResignKeyNotification object:nil];
    
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
    
    if(prompt.moment == AKPromptMomentImmediate) {
        [self.manager assignPromptWithMoment:AKPromptMomentImmediate];
    }
    dispatch_semaphore_signal(self.manager.semaphore);
}

+ (void)cancle:(id<AKPromptProtocol>)prompt {
    if(!prompt) {
        AKPrompterLog(@"prompt不可为空");
        return;
    }
    
    dispatch_semaphore_wait(self.manager.semaphore, DISPATCH_TIME_FOREVER);
    [self.manager.waitingPromptsM removeObject:prompt];
    [self.manager.queuePromptsM removeObject:prompt];
    
    if(prompt.moment == AKPromptMomentImmediate) {
        [self.manager assignPromptWithMoment:AKPromptMomentImmediate];
    }
    dispatch_semaphore_signal(self.manager.semaphore);
}

#pragma mark - Private Method
- (void)assignPromptWithMoment:(AKPromptMoment)moment {
    NSArray<id<AKPromptProtocol>> *waitingPrompts = [self.waitingPromptsM copy];
    if(!waitingPrompts.count) {
        return;
    }
    
    BOOL isMoment = NO;
    
    for(id<AKPromptProtocol> prompt in waitingPrompts) {
        if(prompt.moment != moment) {
            continue;
        }
        
        isMoment = YES;
        
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
    
    if(!isMoment) {
        return;
    }
    
    [self promptNext];
}

- (void)promptNext {
    if(self.isOtherWindowVisible) {
        return;
    }
    
    NSArray<id<AKPromptProtocol>> *queuePrompts = [self.queuePromptsM copy];
    
    //如果没有可以显示的prompt，则替换UIWindow
    if(!queuePrompts.count) {
        //已经展示的prompt需要执行完
        if(self.currentPrompt) {
            return;
        }
        
        if(!UIApplication.sharedApplication.delegate.window.isKeyWindow) {
            [UIApplication.sharedApplication.delegate.window makeKeyAndVisible];
            self.window = nil;
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

/**
 以下是【应用启动->系统弹窗->弹窗关闭】流程下的UIWindow变化，可见：
 （1）系统弹窗只有BecomeVisible，并未BecomeKey
 （2）UIApplication.sharedApplication.delegate.window不仅没有ResignKey，而且没有BecomeHidden
 
name = UIWindowDidBecomeVisibleNotification; object = <UIStatusBarWindow: 0x127d097d0;
name = UIWindowDidBecomeVisibleNotification; object = <UIWindow: 0x127d09b30;
name = UIWindowDidBecomeKeyNotification; object = <UIWindow: 0x127d09b30;
name = UIWindowDidBecomeVisibleNotification; object = <_UIAlertControllerShimPresenterWindow: 0x127d0d700;
name = UIWindowDidBecomeVisibleNotification; object = <UITextEffectsWindow: 0x127d24e20;
name = UIWindowDidBecomeHiddenNotification; object = <_UIAlertControllerShimPresenterWindow: 0x127d0d700;
 */

/**
 以下是【应用启动->Prompt弹窗->弹窗关闭】流程下的UIWindow变化，可见：
 （1）自定义UIWindow有BecomeVisible，有BecomeKey
 （2）UIApplication.sharedApplication.delegate.window有ResignKey，但是没有BecomeHidden
 
name = UIWindowDidBecomeVisibleNotification; object = <UIStatusBarWindow: 0x147d04290;
name = UIWindowDidBecomeVisibleNotification; object = <UIWindow: 0x147d05a90;
name = UIWindowDidBecomeKeyNotification; object = <UIWindow: 0x147d05a90;
name = UIWindowDidBecomeVisibleNotification; object = <UIWindow: 0x147e01f40;
name = UIWindowDidResignKeyNotification; object = <UIWindow: 0x147d05a90;
name = UIWindowDidBecomeKeyNotification; object = <UIWindow: 0x147e01f40;
name = UIWindowDidResignKeyNotification; object = <UIWindow: 0x147e01f40;
name = UIWindowDidBecomeKeyNotification; object = <UIWindow: 0x147d05a90;
 */

- (void)onUIWindowDidBecomeVisibleNotification:(NSNotification *)notification {
    AKPrompterLog(@"%@", notification);
    
    UIWindow *currentWindow = notification.object;
    if(![currentWindow isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    if([currentWindow isKindOfClass:NSClassFromString(@"UIStatusBarWindow")]) {
        return;
    }
    
    if(currentWindow == UIApplication.sharedApplication.delegate.window
       || currentWindow == self.window) {
        return;
    }
    
    /**
     对于UIAlertView或者UIAlertController来讲，都会具有一个UITextEffectsWindow，但是这个Window只会触发BecomeVisible通知，而不会触发BecomeHidden通知，导致判断逻辑失效
     */
    if([currentWindow isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
        return;
    }
    
    //如果不是自定义类
    if([NSBundle bundleForClass:[currentWindow class]] != NSBundle.mainBundle) {
        self.otherWindowVisible = YES;
        
        if(!self.currentPrompt) {
            return;
        }
        
        [self.currentPrompt.content disappear];
        self.currentPrompt = nil;
    }
}

- (void)onUIWindowDidBecomeHiddenNotification:(NSNotification *)notification {
    AKPrompterLog(@"%@", notification);
    
    UIWindow *currentWindow = notification.object;
    if(![currentWindow isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    if([currentWindow isKindOfClass:NSClassFromString(@"UIStatusBarWindow")]) {
        return;
    }
    
    if(currentWindow == UIApplication.sharedApplication.delegate.window
       || currentWindow == self.window) {
        return;
    }
    
    if([currentWindow isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
        return;
    }
    
    //如果不是自定义类
    if([NSBundle bundleForClass:[currentWindow class]] != NSBundle.mainBundle) {
        self.otherWindowVisible = NO;
        [self promptNext];
    }
}

- (void)onUIWindowDidBecomeKeyNotification:(NSNotification *)notification {
    AKPrompterLog(@"%@", notification);
    
    UIWindow *currentWindow = notification.object;
    if(![currentWindow isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    if(currentWindow == UIApplication.sharedApplication.delegate.window) {
        self.otherWindowVisible = NO;
    } else if(currentWindow == self.window) {
        self.otherWindowVisible = NO;
        [self promptNext];
    }
}

- (void)onUIWindowDidResignKeyNotification:(NSNotification *)notification {
    AKPrompterLog(@"%@", notification);
    
    UIWindow *currentWindow = notification.object;
    if(![currentWindow isKindOfClass:[UIWindow class]]) {
        return;
    }
    
    if(currentWindow == UIApplication.sharedApplication.delegate.window) {
        self.otherWindowVisible = YES;
    } else if(currentWindow == self.window) {
        self.otherWindowVisible = YES;
        
        if(!self.currentPrompt) {
            return;
        }
        
        [self.currentPrompt.content disappear];
        self.currentPrompt = nil;
    }
}

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
    _window.windowLevel = UIApplication.sharedApplication.delegate.window.windowLevel;
    return _window;
}

@end
