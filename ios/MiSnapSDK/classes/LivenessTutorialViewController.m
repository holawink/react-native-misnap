//
//  LivenessTutorialViewController.m
//  SampleApp
//
//  Created by Jeremy Jessup on 4/26/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import "LivenessTutorialViewController.h"
#import "AutosizeLabel.h"
#import <AVFoundation/AVFoundation.h>

#define EYES_OPEN_IMG			(@"tutorial-help-auto-animation-2")
#define EYES_CLOSED_IMG			(@"tutorial-help-auto-animation-1")

@interface LivenessTutorialViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation LivenessTutorialViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationController.navigationBar.hidden = YES;
	
	NSArray *animArray = @[
						   [UIImage imageNamed:EYES_OPEN_IMG],
						   [UIImage imageNamed:EYES_OPEN_IMG],
						   [UIImage imageNamed:EYES_OPEN_IMG],
						   [UIImage imageNamed:EYES_CLOSED_IMG],
						   ];
	
	self.imageView.image = animArray.firstObject;
	self.imageView.animationImages = animArray;
	self.imageView.animationDuration = 0.75f;
	self.imageView.animationRepeatCount = 0;

	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgd-dots-transparent"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.imageView startAnimating];
}

- (IBAction)startButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tutorialStartButtonPressed)])
    {
        [self.delegate tutorialStartButtonPressed];
    }
    if (self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.navigationController)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(tutorialCancelButtonPressed)])
    {
        [self.delegate tutorialCancelButtonPressed];
    }
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass([self class]);
}

+ (LivenessTutorialViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"FacialCaptureUX" bundle:nil] instantiateViewControllerWithIdentifier:[LivenessTutorialViewController storyboardIdentifier]];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc
{
    //NSLog(@"LivenessTutorialViewController is being deallocated");
}

@end
