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

@interface AKViewController ()

@end

@implementation AKViewController

+ (void)load {
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
    
    AKPrompt *prompt = [[AKPrompt alloc] init];
    prompt.moment = AKPromptMomentImmediate;
    prompt.priority = AKPromptPriorityRequired;
    
    AKTestView *testView = [[AKTestView alloc] initWithColor:UIColor.greenColor targetFrame:CGRectMake(10., 100., 50., 50.)];
    prompt.content = testView;
    
    [AKPromptManager prompt:prompt];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AKPrompt *prompt1 = [[AKPrompt alloc] init];
        prompt1.moment = AKPromptMomentBecomeActive;
        prompt1.priority = AKPromptPriorityRequired;
        
        AKTestView *testView1 = [[AKTestView alloc] initWithColor:UIColor.yellowColor targetFrame:CGRectMake(10., 200., 50., 50.)];
        prompt1.content = testView1;
        
        [AKPromptManager prompt:prompt1];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
