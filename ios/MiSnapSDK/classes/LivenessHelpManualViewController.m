//
//  LivenessHelpManualViewController.m
//  SampleApp
//
//  Created by Jeremy Jessup on 5/12/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import "LivenessHelpManualViewController.h"
#import "AutosizeLabel.h"
#import "LabelUtils.h"

@interface LivenessHelpManualViewController ()
@property (strong, nonatomic) IBOutlet AutosizeLabel *centerFaceLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *neutralExpressionLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *noHatsLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *noGlassesLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *pleaseDoLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *dontLabel;
@end

@implementation LivenessHelpManualViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSArray *faceLabels = @[self.centerFaceLabel, self.neutralExpressionLabel, self.noHatsLabel, self.noGlassesLabel];
	[LabelUtils resizeLabels:faceLabels];
	
	NSArray *titleLabels = @[self.pleaseDoLabel, self.dontLabel];
	[LabelUtils resizeLabels:titleLabels];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkgd-dots-transparent"]];
}

- (IBAction)continueButtonPressed:(id)sender
{
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

+ (LivenessHelpManualViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"FacialCaptureUX" bundle:nil] instantiateViewControllerWithIdentifier:[LivenessHelpManualViewController storyboardIdentifier]];
}

- (void)dealloc
{
    //NSLog(@"LivenessHelpManualViewController is being deallocated");
}

@end
