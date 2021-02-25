//
//  MiSnapSDKTutorialViewController.m
//  MiSnap
//
//  Created by Greg Fisch on 7/30/14.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import "MiSnapSDKTutorialViewController.h"
#import <MiSnapSDK/MiSnapSDK.h>

@interface MiSnapSDKTutorialViewController ()

@property (nonatomic) UILabel *dontShowLabel;
@property (nonatomic) UIImageView *checkboxImageView;
@property (nonatomic) UIView *tapView;
@property (nonatomic) BOOL shouldShowFirstTimeTutorial;
@property (nonatomic) UIInterfaceOrientation statusbarOrientation;
@property (nonatomic) MiSnapSDKResourceLocator* resourceLocator;

@end

@implementation MiSnapSDKTutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _numberOfButtons = 2;
        _timeoutDelay = 0;
        _languageOverride = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    self.resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.languageOverride];
    
    [self.cancelButton setTitle:[self.resourceLocator getLocalizedString:@"dialog_mitek_cancel"] forState:UIControlStateNormal];
    [self.cancelButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"dialog_mitek_cancel"]];
    self.cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if ((self.isManualMode && self.numberOfButtons != 1) || self.numberOfButtons == 3)
    {
        [self.continueButton setTitle:[self.resourceLocator getLocalizedString:@"dialog_mitek_manual_capture"] forState:UIControlStateNormal];
        [self.continueButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"dialog_mitek_manual_capture"]];
        [self.retryButton setTitle:[self.resourceLocator getLocalizedString:@"dialog_mitek_try_again"] forState:UIControlStateNormal];
        [self.retryButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"dialog_mitek_try_again"]];
    }
    else
    {
        [self.continueButton setTitle:[self.resourceLocator getLocalizedString:@"dialog_mitek_capture"] forState:UIControlStateNormal];
        [self.continueButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"dialog_mitek_capture"]];
        [self.retryButton setTitle:[self.resourceLocator getLocalizedString:@"dialog_mitek_capture"] forState:UIControlStateNormal];
        [self.retryButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"dialog_mitek_capture"]];
    }
    
    self.continueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // Show "Don't show this screen again" checkbox only for ID docs (DL, ID card, Passport)
    if (self.tutorialMode == MiSnapTutorialModeFirstTime)
    {
        if ([self.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
            [self.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
            [self.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack] ||
            [self.documentType isEqualToString:kMiSnapDocumentTypePassport])
        {
            [self addDontShowAgainCheckbox];
        }
    }
    
    // Remove text and set image tutorial for ID docs (DL, ID card front and back, Passport)
    if (self.tutorialMode == MiSnapTutorialModeFirstTime) // || self.tutorialMode == MiSnapTutorialModeHelp
    {
        if ([self.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense])
        {
            self.backgroundImageName = @"misnap_tutorial_id_with_background";
            
            // remove view with dynamically generated text and red arrows
            UIView *v = [self.view viewWithTag:1111];
            [v removeFromSuperview];
        }
        else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront])
        {
            self.backgroundImageName = @"misnap_tutorial_id_with_background";
            
            // remove view with dynamically generated text and red arrows
            UIView *v = [self.view viewWithTag:1111];
            [v removeFromSuperview];
        }
        else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
        {
            self.backgroundImageName = @"misnap_tutorial_id_back_with_background";
            
            // remove view with dynamically generated text and red arrows
            UIView *v = [self.view viewWithTag:1111];
            [v removeFromSuperview];
        }
        else if ([self.documentType isEqualToString:kMiSnapDocumentTypePassport])
        {
            self.backgroundImageName = @"misnap_tutorial_passport_with_background";
            
            // remove view with dynamically generated text and red arrows
            UIView *v = [self.view viewWithTag:1111];
            [v removeFromSuperview];
        }
    }
    
    if ((self.backgroundImageName != nil) && ([self.backgroundImageName isEqualToString:@""] == NO))
    {
        self.backgroundImageView.image = [self.resourceLocator getLocalizedTutorialImage:self.backgroundImageName withOrientation:self.statusbarOrientation withOrientationMode:self.orientationMode];
        [self.view bringSubviewToFront:self.backgroundImageView];
    }
    else
    {
        self.backgroundImageView.image = nil;
    }
    
    [self.view addSubview:self.dontShowLabel];
    [self.view addSubview:self.checkboxImageView];
    [self.view addSubview:self.tapView];
    
    if (self.navigationController != nil)
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    if (self.timeoutDelay == 0.0)
    {
        [self showButtons];
    }
    else
    {
        self.cancelButton.alpha = 0.0;
        self.retryButton.alpha = 0.0;
        self.continueButton.alpha = 0.0;
        self.buttonBackgroundView.alpha = 0.0;
        
        if (self.numberOfButtons == 0)
            [self performSelector:@selector(continueButtonAction:) withObject:nil afterDelay:self.timeoutDelay/1000.0];
        else
            [self performSelector:@selector(showButtons) withObject:nil afterDelay:self.timeoutDelay/1000.0];
    }
    
    if (self.orientationMode == MiSnapOrientationModeDeviceLandscapeGhostLandscape &&
        ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ||
         [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context)
    {
        self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if ((self.backgroundImageName != nil) && ([self.backgroundImageName isEqualToString:@""] == NO))
        {
            self.backgroundImageView.image = [self.resourceLocator getLocalizedTutorialImage:self.backgroundImageName withOrientation:self.statusbarOrientation withOrientationMode:self.orientationMode];
            [self.view bringSubviewToFront:self.backgroundImageView];
        }
        else
        {
            self.backgroundImageView.image = nil;
        }
        
        CGFloat offset = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && size.width / size.height > 1.8 && UIInterfaceOrientationIsLandscape(self.statusbarOrientation))
        {
            offset = 20;
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && size.height / size.width > 1.8 && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
        {
            offset = 35;
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            offset = 30;
        }
        
        self.dontShowLabel.center = CGPointMake(size.width * 0.5, size.height - self.buttonBackgroundView.frame.size.height - self.dontShowLabel.frame.size.height - offset);
        self.checkboxImageView.center = CGPointMake(self.dontShowLabel.center.x - self.dontShowLabel.frame.size.width * 0.5 - self.checkboxImageView.frame.size.width * 0.5 - 5, self.dontShowLabel.center.y);
        self.tapView.center = CGPointMake(self.dontShowLabel.center.x - self.checkboxImageView.frame.size.width * 0.5, self.dontShowLabel.center.y);
        [self.view bringSubviewToFront:self.dontShowLabel];
        [self.view bringSubviewToFront:self.checkboxImageView];
        [self.view bringSubviewToFront:self.tapView];
    }
    completion:nil];
}

#pragma mark - Implementation

- (void)setNumberOfButtons:(int)numberOfButtons
{
    if (numberOfButtons < 0)
        _numberOfButtons = 0;
    else if (numberOfButtons > 3)
        _numberOfButtons = 3;
    else
        _numberOfButtons = numberOfButtons;
}

- (void)showButtons
{
    if ((self.speakableText != nil) && ([self.speakableText isEqualToString:@""] == NO))
    {
        MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.languageOverride];
        NSString* localizedStr = [resourceLocator getLocalizedString:self.speakableText];
        
        self.backgroundImageView.accessibilityLabel = localizedStr;
        
        // For testing only
        //         UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, localizedStr);
        // OR
        //        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[self getLocalizedString:self.speakableText]];
        //        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        //        [synth speakUtterance:utterance];
    }
    
    if (_numberOfButtons == 0)
    {
        self.cancelButton.hidden = YES;
        self.retryButton.hidden = YES;
        self.continueButton.hidden = YES;
        
        self.cancelButton.enabled = NO;
        self.retryButton.enabled = NO;
        self.continueButton.enabled = NO;
        
        self.buttonBackgroundView.hidden = YES;
    }
    else if (_numberOfButtons == 1)
    {
        self.cancelButton.hidden = YES;
        self.retryButton.hidden = NO;
        self.continueButton.hidden = YES;
        
        self.cancelButton.enabled = NO;
        self.retryButton.enabled = YES;
        self.continueButton.enabled = NO;
        
        self.buttonBackgroundView.hidden = NO;
    }
    else if (_numberOfButtons == 2)
    {
        self.cancelButton.hidden = NO;
        self.retryButton.hidden = YES;
        self.continueButton.hidden = NO;
        
        self.cancelButton.enabled = YES;
        self.retryButton.enabled = NO;
        self.continueButton.enabled = YES;
        
        self.buttonBackgroundView.hidden = NO;
    }
    else if (_numberOfButtons == 3)
    {
        self.cancelButton.hidden = NO;
        self.retryButton.hidden = NO;
        self.continueButton.hidden = NO;
        
        self.cancelButton.enabled = YES;
        self.retryButton.enabled = YES;
        self.continueButton.enabled = YES;
        
        self.buttonBackgroundView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.cancelButton.alpha = 1.0;
        self.retryButton.alpha = 1.0;
        self.continueButton.alpha = 1.0;
        self.buttonBackgroundView.alpha = 1.0;
    }];
}

- (IBAction)cancelButtonAction:(id)sender
{    
    if ([self.delegate respondsToSelector:@selector(tutorialCancelButtonAction)])
    {
        [self.delegate tutorialCancelButtonAction];
    }
}

- (IBAction)continueButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tutorialContinueButtonAction)])
    {
        [self.delegate tutorialContinueButtonAction];
    }
}

- (IBAction)retryButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tutorialRetryButtonAction)])
    {
        [self.delegate tutorialRetryButtonAction];
    }
}

- (void)addDontShowAgainCheckbox
{
    self.shouldShowFirstTimeTutorial = YES;
    
    if ([self.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialDl"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialPassport"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialIdFront"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialIdBack"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat offset = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && screenWidth / screenHeight > 1.8 && UIInterfaceOrientationIsLandscape(self.statusbarOrientation))
    {
        offset = 20;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && screenHeight / screenWidth > 1.8 && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
    {
        offset = 35;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        offset = 30;
    }
    
    NSString *dontShowString = [self.resourceLocator getLocalizedString:@"misnap_tutorial_do_not_show_again"];
    CGFloat dontShowAgainFontSize = 16.0;
    
    CGSize maximumSize = CGSizeMake(screenWidth * 0.9, 50);
    CGRect dontShowRect = [dontShowString boundingRectWithSize:maximumSize options:NSStringDrawingTruncatesLastVisibleLine attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:dontShowAgainFontSize] } context:nil];
    //NSLog(@"Don't show this again size: %@", NSStringFromCGRect(dontShowRect));
    
    self.dontShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dontShowRect.size.width, dontShowRect.size.height)];
    self.dontShowLabel.center = CGPointMake(screenWidth * 0.5, screenHeight - self.buttonBackgroundView.frame.size.height - self.dontShowLabel.frame.size.height - offset);
    self.dontShowLabel.text = dontShowString;
    self.dontShowLabel.font = [UIFont systemFontOfSize:dontShowAgainFontSize];
    [self.dontShowLabel setTextColor:[UIColor blackColor]];

    self.checkboxImageView = [[UIImageView alloc] init];
    self.checkboxImageView.image = [[MiSnapSDKResourceLocator initWithLanguageKey:self.languageOverride] getLocalizedImage:@"checkbox_unchecked"];
    self.checkboxImageView.frame = CGRectMake(0, 0, dontShowRect.size.height - 5, dontShowRect.size.height - 5);
    self.checkboxImageView.center = CGPointMake(self.dontShowLabel.center.x - self.dontShowLabel.frame.size.width * 0.5 - self.checkboxImageView.frame.size.width * 0.5 - 5, self.dontShowLabel.center.y);
    
    self.tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.checkboxImageView.frame.size.width + self.dontShowLabel.frame.size.width + 30, self.dontShowLabel.frame.size.height + 20)];
    self.tapView.center = CGPointMake(self.dontShowLabel.center.x - self.checkboxImageView.frame.size.width * 0.5, self.dontShowLabel.center.y);
    self.tapView.userInteractionEnabled = YES;
    self.tapView.accessibilityIdentifier = dontShowString;
    
    UITapGestureRecognizer *dontShowTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dontShowTapped)];
    dontShowTap.numberOfTapsRequired = 1;
    [self.tapView addGestureRecognizer:dontShowTap];
}

- (void)dontShowTapped
{
    //NSLog(@"Don't show was tapped");
    if (self.shouldShowFirstTimeTutorial)
    {
        self.checkboxImageView.image = [[MiSnapSDKResourceLocator initWithLanguageKey:self.languageOverride] getLocalizedImage:@"checkbox_checked"];
        self.shouldShowFirstTimeTutorial = NO;
    }
    else
    {
        self.checkboxImageView.image = [[MiSnapSDKResourceLocator initWithLanguageKey:self.languageOverride] getLocalizedImage:@"checkbox_unchecked"];
        self.shouldShowFirstTimeTutorial = YES;
    }
    
    if ([self.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialDl"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialPassport"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialIdFront"];
    }
    else if ([self.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
    {
        [[NSUserDefaults standardUserDefaults] setBool:self.shouldShowFirstTimeTutorial forKey:@"MiSnapShowTutorialIdBack"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
