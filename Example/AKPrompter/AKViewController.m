//
//  AKViewController.m
//  AKPrompter
//
//  Created by Freud on 06/12/2017.
//  Copyright (c) 2017 Freud. All rights reserved.
//

#import "AKViewController.h"
#import <AKPrompter/AKPromptManager.h>
#import <AKPrompter/AKPrompt.h>
#import "AKTestView.h"
#import "AKTestController.h"

@interface AKViewController ()

@end

@implementation AKViewController

+ (void)load {
    return;
    
    AKPrompt *prompt = [[AKPrompt alloc] init];
    prompt.moment = AKPromptMomentLaunchFinish;
    prompt.priority = AKPromptPriorityLow;
    
    AKTestView *testView = [[AKTestView alloc] initWithColor:UIColor.cyanColor targetFrame:CGRectMake(10., 10., 50., 50.)];
    prompt.content = testView;
    
    [AKPromptManager prompt:prompt];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.whiteColor;
    
//    return;
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"系统弹窗" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        [controller addAction:action];
//        
//        [self presentViewController:controller animated:YES completion:^{
//            
//        }];
//    });
//
//    return;
    
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imagePickerController.allowsEditing = YES;
//    imagePickerController.delegate = (id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)self;
//    [self.navigationController presentViewController:imagePickerController animated:YES completion:^{
//        NSLog(@"");
//    }];
    
    //[[[UIAlertView alloc] initWithTitle:@"系统弹窗1" message:@"" delegate:nil cancelButtonTitle:@"Hidden" otherButtonTitles: nil] show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //return;
        
        AKPrompt *prompt = [[AKPrompt alloc] init];
        prompt.moment = AKPromptMomentImmediate;
        prompt.priority = AKPromptPriorityRequired;
        
        AKTestController *testController = [[AKTestController alloc] init];
        AKTestView *testView = [[AKTestView alloc] initWithColor:UIColor.greenColor targetFrame:UIScreen.mainScreen.bounds];
        prompt.content = testController;
        
        [AKPromptManager prompt:prompt];
        
        //[[[UIAlertView alloc] initWithTitle:@"系统弹窗1" message:@"" delegate:nil cancelButtonTitle:@"Hidden" otherButtonTitles: nil] show];
        
        //[[[UIAlertView alloc] initWithTitle:@"系统弹窗2" message:@"" delegate:nil cancelButtonTitle:@"Hidden" otherButtonTitles: nil] show];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        return;
        
        [[[UIAlertView alloc] initWithTitle:@"系统弹窗1" message:@"" delegate:nil cancelButtonTitle:@"Hidden" otherButtonTitles: nil] show];
    });

    return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"系统弹窗" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:action];
        
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:controller animated:YES completion:^{
            
        }];
        
//        [self.navigationController presentViewController:controller animated:YES completion:^{
//            
//        }];
    });
    
    return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AKPrompt *prompt1 = [[AKPrompt alloc] init];
        prompt1.moment = AKPromptMomentBecomeActive;
        prompt1.priority = AKPromptPriorityRequired;
        
        AKTestView *testView1 = [[AKTestView alloc] initWithColor:UIColor.yellowColor targetFrame:CGRectMake(10., 200., 50., 50.)];
        prompt1.content = testView1;
        
        [AKPromptManager prompt:prompt1];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
//    return UIInterfaceOrientationMaskPortrait;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
