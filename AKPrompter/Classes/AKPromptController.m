//
//  AKPromptController.m
//  Pods
//
//  Created by 李翔宇 on 2017/6/26.
//
//

#import "AKPromptController.h"

@interface AKPromptController ()

@end

@implementation AKPromptController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override Method

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        [UIApplication.sharedApplication.delegate.window.rootViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    if([modalViewController isKindOfClass:[UIAlertController class]]) {
        [UIApplication.sharedApplication.delegate.window.rootViewController presentModalViewController:modalViewController animated:animated];
        return;
    }
    
    [super presentModalViewController:modalViewController animated:animated];
}

- (BOOL)shouldAutorotate {
    UIViewController *controller = UIApplication.sharedApplication.delegate.window.rootViewController;
    if(controller.presentedViewController) {
        return controller.presentedViewController.shouldAutorotate;
    }
    return controller.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *controller = UIApplication.sharedApplication.delegate.window.rootViewController;
    if(controller.presentedViewController) {
        return controller.presentedViewController.supportedInterfaceOrientations;
    }
    return controller.supportedInterfaceOrientations;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *controller = UIApplication.sharedApplication.delegate.window.rootViewController;
    if(controller.presentedViewController) {
        return controller.presentedViewController.preferredInterfaceOrientationForPresentation;
    }
    return controller.preferredInterfaceOrientationForPresentation;
}

@end
