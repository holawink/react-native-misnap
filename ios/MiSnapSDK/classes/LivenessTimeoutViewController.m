//
//  TimeoutViewController.m
//  SampleApp
//
//  Created by Jeremy Jessup on 5/13/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import "LivenessTimeoutViewController.h"
#import <MiSnapLiveness/MiSnapLiveness.h>

@interface LivenessTimeoutViewController ()

@end

@implementation LivenessTimeoutViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgd-dots-transparent"]];
}

- (IBAction)autoButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(retryAuto:)])
    {
        [self.delegate retryAuto:YES];
    }
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)manualButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(retryAuto:)])
    {
        [self.delegate retryAuto:NO];
    }
	
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.navigationController)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(tutorialCancelButtonPressed)])
        {
            [self.delegate tutorialCancelButtonPressed];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass([self class]);
}

+ (LivenessTimeoutViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"FacialCaptureUX" bundle:nil] instantiateViewControllerWithIdentifier:[LivenessTimeoutViewController storyboardIdentifier]];
}

- (void)dealloc
{
    //NSLog(@"LivenessTimeoutViewController is being deallocated");
}

@end
