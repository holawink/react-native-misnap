//
//  LivenessHelpAutoViewController.m
//  SampleApp
//
//  Created by Jeremy Jessup on 4/11/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import "LivenessHelpAutoViewController.h"
#import "LabelUtils.h"
#import "AutosizeLabel.h"

@interface LivenessHelpAutoViewController ()
@property (strong, nonatomic) IBOutlet AutosizeLabel *centerFaceLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *neutralFaceLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *blinkLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *noHatsLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *noGlassesLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *pleaseDoLabel;
@property (strong, nonatomic) IBOutlet AutosizeLabel *dontLabel;
@end

@implementation LivenessHelpAutoViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSArray *labelArray = @[self.centerFaceLabel, self.neutralFaceLabel, self.blinkLabel, self.noHatsLabel, self.noGlassesLabel];
	[LabelUtils resizeLabels:labelArray];
	
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

+ (LivenessHelpAutoViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"FacialCaptureUX" bundle:nil] instantiateViewControllerWithIdentifier:[LivenessHelpAutoViewController storyboardIdentifier]];
}

- (void)dealloc
{
    //NSLog(@"LivenessHelpAutoViewController is being deallocated");
}

@end
