//
//  MiSnapSDKOverlayViewUX2.m
//  MiSnap
//
//  Created by Greg Fisch on 1/28/15.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import <MiSnapSDK/MiSnapSDK.h>
#import "MiSnapSDKOverlayViewUX2.h"
#import "MiSnapSDKViewControllerUX2.h"

@interface MiSnapSDKOverlayViewUX2()

@property (nonatomic, strong) UIImageView* hintView;
@property (nonatomic, strong) NSTimer* hintTimer;
@property (nonatomic, strong) NSDictionary* params;

@property (nonatomic, strong) UIButton* smartHint;
@property (nonatomic, strong) UIButton* smartGlareBox;
@property (nonatomic, strong) NSTimer* smartHintTimer;

@property (nonatomic, strong) MiSnapSDKParameters* docCaptureParams;

@property (nonatomic, strong) MiSnapSDKResourceLocator* resourceLocator;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ghostImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ghostImageHeightConstraint;

@property (nonatomic, assign) CGFloat smartHintDelay;

@property (nonatomic, assign) CGFloat aspectRatio;

@property (nonatomic, strong) NSDate *firstHintTime;
@property (nonatomic, assign) BOOL isFirstTimeHint;
@property (nonatomic, assign) NSTimeInterval firstHintDelayTime;

@property (nonatomic, assign) BOOL gaugeIsOpen;
@property (nonatomic, assign) BOOL isShowingHint;
@property (nonatomic, assign) BOOL isShowingSmartHint;
@property (nonatomic, assign) int completionScore;

@property (nonatomic, assign) CGRect guideDotRect;

// Settings for SmartHint
@property (nonatomic, strong) UIColor *smartHintBackgroundColor;
@property (nonatomic, strong) UIColor *smartHintBorderColor;
@property (nonatomic, strong) UIColor *smartHintTextColor;
@property (nonatomic, strong) UIFont *smartHintFont;
@property (nonatomic, assign) float smartHintBorderWidth;
@property (nonatomic, assign) float smartHintCornerRadius;

// Settings for SmartBox (glare box)
@property (nonatomic, strong) UIColor *glareBoxBackgroundColor;
@property (nonatomic, strong) UIColor *glareBoxBorderColor;
@property (nonatomic, assign) float glareBoxBorderWidth;
@property (nonatomic, assign) float glareBoxCornerRadius;

// Settings to show or hide SmartHints
@property (nonatomic, assign) BOOL shouldShowSmartHintGlare;
@property (nonatomic, assign) BOOL shouldShowSmartHintNotCheckBack;
@property (nonatomic, assign) BOOL shouldShowSmartHintNotCheckFront;
@property (nonatomic, assign) BOOL shouldShowSmartHintLowContrast;
@property (nonatomic, assign) BOOL shouldShowSmartHintBusyBackground;

@end


@implementation MiSnapSDKOverlayViewUX2

@dynamic aspectRatio;
@dynamic torchButton;
@dynamic snapButton;
@dynamic jobTitleLabel;
@dynamic ghostTextLabel;
@dynamic ghostImageView;

- (id)init
{
    self = [super init];
    if (self) {
        [self initializeObjects];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeObjects];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeObjects];
    }
    return self;
}

- (void)initializeObjects
{
    self.ghostTextLabel.hidden = TRUE;
    
    self.gaugeIsOpen = FALSE;
    self.isShowingHint = FALSE;
    self.isShowingSmartHint = FALSE;
    self.completionScore = 0;
    
    self.hintTimer = nil;
    
    self.jobTitleLabel.text = @"";
    
    self.smartHintBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7f];
    self.smartHintBorderColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    self.smartHintTextColor = [[UIColor darkTextColor] colorWithAlphaComponent:1.0f];
    self.smartHintFont = [UIFont fontWithName:@"Helvetica" size:28];
    self.smartHintBorderWidth = 0.0f;
    self.smartHintCornerRadius = 18.0f;
    
    self.glareBoxBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
    self.glareBoxBorderColor = [[UIColor redColor] colorWithAlphaComponent:0.9f];
    self.glareBoxBorderWidth = 6.0f;
    self.glareBoxCornerRadius = 8.0f;

    self.shouldShowSmartHintGlare = YES; // YES, display glare hint.
    self.shouldShowSmartHintNotCheckBack = YES;  // YES, display not check back hint.
    self.shouldShowSmartHintNotCheckFront = YES;  // YES, display not check front hint.
    self.shouldShowSmartHintLowContrast = YES;  // YES, display low contrast hint.
    self.shouldShowSmartHintBusyBackground = YES;  // YES, display busy background hint.
    
    self.successImageView.hidden = YES; //Hide the success view so it won't show even briefly during the check for camera permissions

//    isFirstTime = TRUE;
//    isFirstTimeHint = TRUE;
    
    CGFloat biggerSide = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
    CGFloat smallerSide = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
    
    self.aspectRatio = biggerSide / smallerSide;
    
    self.isFirstTimeHint = YES;
    
    // Set a small delay so the first hint won't appear to early (possibly with a wrong hint)
    self.firstHintDelayTime = 1.0;
}

- (void)sayText:(NSString *)textStr
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [self.resourceLocator getLocalizedString:textStr]);
}

#pragma mark - Animation

- (void)animateHint:(UIImageView*)hintView
{
    CGFloat xStart = (self.bounds.size.width - hintView.image.size.width) / 2;
    CGFloat yStart = (self.bounds.size.height - hintView.image.size.height) / 2;

    [hintView setAlpha:0.0];
	[hintView.layer setAnchorPoint:CGPointMake(0.5, 1.0)];
	[hintView setFrame:CGRectMake(xStart, yStart, hintView.image.size.width, hintView.image.size.height)];
	[self addSubview:hintView];
    UIView *smartView = [self viewWithTag:12345];
    if (smartView) {
        // Keep a smart hint showing on top of hint
        [self bringSubviewToFront:smartView];
    }
    UIView *smartBox = [self viewWithTag:123456];
    if (smartBox) {
        // Keep a smart box showing on top of all other hints
        [self bringSubviewToFront:smartBox];
    }
    
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [hintView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             [hintView setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [hintView removeFromSuperview];
                         }];
                    }];
}

- (void)animateSmartHint:(UIView*)hintView
{
    [hintView setAlpha:0.0];
    [self addSubview:hintView];
    
    self.isShowingSmartHint = TRUE;
    self.isShowingHint = TRUE;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [hintView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             [hintView setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [hintView removeFromSuperview];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.smartHintDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 self.isShowingSmartHint = FALSE;
                                 self.isShowingHint = FALSE;
                             });
                         }];
                     }];
}

- (void)animateSmartHint:(UIView*)hintView withGlareBox:(UIView*)glareView
{
    [hintView setAlpha:0.0];
    [glareView setAlpha:0.0];
    [self addSubview:hintView];
    [self addSubview:glareView];
    
    self.isShowingSmartHint = TRUE;
    self.isShowingHint = TRUE;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [hintView setAlpha:1.0];
                         [glareView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             [hintView setAlpha:0.0];
                             [glareView setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [hintView removeFromSuperview];
                             [glareView removeFromSuperview];
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.smartHintDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 self.isShowingSmartHint = FALSE;
                                 self.isShowingHint = FALSE;
                             });
                         }];
                     }];
}

#pragma mark - External methods

- (void)setupViewWithParams:(NSDictionary *)params;
{
    self.params = [NSDictionary dictionaryWithDictionary:params];

    self.docCaptureParams = [MiSnapSDKParameters new];
    [self.docCaptureParams updateParameters:params];
    self.resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];

    self.successImageView.hidden = YES;
    self.successImageView.layer.cornerRadius = 12.0f;
    [self.successLabel setText:[self.resourceLocator getLocalizedString:@"dialog_success"]];
    [self.successLabel setTextColor:[UIColor blackColor]];
    self.successLabel.hidden = YES;

    self.ghostImageView.hidden = YES;
    self.ghostImageView.alpha = 1.0;

    self.guideDotImageView.hidden = YES;
    self.snapAnimationView.hidden = YES;

    if (self.hintView != nil)
        self.hintView.hidden = YES;

    [self setupJobTitle];

    [self.cancelButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_cancel_button"]];
    [self.snapButton   setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_capture_button"]];
    [self.torchButton  setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_flash_off"]];
    [self.helpButton   setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_help_button"]];

    [self.helpButton setEnabled:YES];
    self.helpButton.hidden = NO;
    self.cancelButton.hidden = NO;
    self.jobTitleLabel.hidden = NO;
    
    // Add localized label to cancel button
    CGRect backFrame = self.cancelButton.frame;
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, backFrame.size.width, backFrame.size.height)];
    [backLabel setText:[self.resourceLocator getLocalizedString:@"misnap_overlay_cancel_button"]];
    [backLabel setTextColor:[UIColor orangeColor]];
    [self.cancelButton addSubview:backLabel];

    /////////////////////////////////////////////////////////////////////////////
    // WARNING: Do not comment out this if statement to make the snapButton
    //          appear and be enabled.  To display an enabled manual button,
    //          go to the MiSnapViewController showMiSnap method and follow
    //          the instructions in the comments
    /////////////////////////////////////////////////////////////////////////////
    int mode = (int)[self.params[kMiSnapCaptureMode] integerValue];
    if ((mode == MiSnapCaptureModeManual)
        || (mode == MiSnapCaptureModeManualAssist)
        || (mode == MiSnapCaptureModeHighResManual))
    {
        self.snapButton.hidden = YES;
        self.snapButton.enabled = NO;
        #if TARGET_IPHONE_SIMULATOR
        self.snapButton.hidden = NO;
        self.snapButton.enabled = NO;
        #endif
        [self updateSnapButtonLocation];
    }
    else
    {
        self.snapButton.hidden = YES;
        self.snapButton.enabled = NO;
    }

    int torchMode = [self.params[kMiSnapTorchMode] intValue];

    if (torchMode == 0)
    {
        [self.torchLabel setText:[self.resourceLocator getLocalizedString:@"dialog_mitek_torch_off"]];
        [self.torchLabel setTextColor:[UIColor darkGrayColor]];
        [self.torchButton setBackgroundImage:[self getResourcePNG:@"misnap_en_button_flash_off"] forState:UIControlStateNormal];
        [self.torchButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_flash_off"]];
    }
    else if (torchMode == 1)
    {
        [self.torchLabel setText:[self.resourceLocator getLocalizedString:@"dialog_mitek_torch_auto"]];
        [self.torchLabel setTextColor:[UIColor orangeColor]];
        [self.torchButton setBackgroundImage:[self getResourcePNG:@"misnap_en_button_flash_auto"] forState:UIControlStateNormal];
        [self.torchButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_flash_auto"]];
    }
    else if (torchMode == 2)
    {
        [self.torchLabel setText:[self.resourceLocator getLocalizedString:@"dialog_mitek_torch_on"]];
        [self.torchLabel setTextColor:[UIColor orangeColor]];
        [self.torchButton setBackgroundImage:[self getResourcePNG:@"misnap_en_button_flash_on"] forState:UIControlStateNormal];
        [self.torchButton setAccessibilityLabel:[self.resourceLocator getLocalizedString:@"misnap_overlay_flash_on"]];
    }
    
    if ([self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypePassport])
    {
        self.torchButton.hidden = YES;
        self.torchLabel.hidden = YES;
    }
    else
    {
        self.torchLabel.hidden = NO;
    }

    [self setGhostImage:self.params[kMiSnapDocumentType] withOrientation:[UIApplication sharedApplication].statusBarOrientation];

    CGRect newFrame = self.guideDotImageView.frame;
    newFrame.origin = CGPointMake(-100, -100);
    self.guideDotImageView.frame = newFrame; // Force it offscreen

    [self performSelector:@selector(sayText:) withObject:self.ghostImageView.accessibilityLabel afterDelay:2.0];

    self.smartHintDelay = self.docCaptureParams.smartHintUpdatePeriod / 1000.0 < 1.3 ? 0.0 : self.docCaptureParams.smartHintUpdatePeriod / 1000.0 - 1.3;
    
    if ([self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypePassport] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack])
    {
        self.topBarImageView.hidden = YES;
        self.bottomBarImageView.hidden = YES;
    }
    else
    {
        self.topBarImageView.hidden = NO;
        self.bottomBarImageView.hidden = NO;
    }
}

- (void)updateSnapButtonLocation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        [self updateSnapButtonRelativeCenterX:0.5 relativeCenterY:0.9 relativeSize:0.07];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        [self updateSnapButtonRelativeCenterX:0.925 relativeCenterY:0.5 relativeSize:0.07];
    }
}

- (void)setGhostImage:(NSString*)documentType withOrientation:(UIInterfaceOrientation)orientation
{
    [super setGhostImage:documentType withOrientation:orientation];
    __weak MiSnapSDKOverlayViewUX2* wself = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        wself.ghostTextLabel.hidden = YES;
    });
}

- (UIImage *)image:(NSString *)imageName withOrientation:(UIInterfaceOrientation)orientation
{
    UIImage *image = nil;
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            image = [UIImage imageNamed:imageName];
            break;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationUnknown:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_portrait", imageName]];
            break;
    }
    
    return image;
}

- (void)setTorchButtonStatus:(BOOL)onFlag
{
    UIImage* image;
    NSString* accessibilityLabel;
    
    if (onFlag == YES)
    {
        image = [self getResourcePNG:@"misnap_en_button_flash_on"];
        accessibilityLabel = [self.resourceLocator getLocalizedString:@"misnap_overlay_flash_on"];
        [self.torchLabel setText:[self.resourceLocator getLocalizedString:@"dialog_mitek_torch_on"]];
        [self.torchLabel setTextColor:[UIColor orangeColor]];
    }
    else
    {
        image = [self getResourcePNG:@"misnap_en_button_flash_off"];
        accessibilityLabel = [self.resourceLocator getLocalizedString:@"misnap_overlay_flash_off"];
        [self.torchLabel setText:[self.resourceLocator getLocalizedString:@"dialog_mitek_torch_off"]];
        [self.torchLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    [self.torchButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.torchButton setAccessibilityLabel:accessibilityLabel];
}

- (void)manageTorchButton:(BOOL)hasTorch
{
    if ([self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack] ||
        [self.params[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypePassport])
    {
        return;
    }
    
    [super manageTorchButton:hasTorch];
    self.torchLabel.hidden = !hasTorch;
}

- (void)updateGaugeValue:(int)fillPercentage {}

- (void)runSnapAnimation
{
    [self hideHint];
    self.successImageView.hidden = NO;
    self.successLabel.hidden = NO;
    
    if (self.docCaptureParams.captureMode != MiSnapCaptureModeManual &&
        self.docCaptureParams.captureMode != MiSnapCaptureModeHighResManual)
    {
        [self sayText:@"dialog_success"];
    }
    
    UIImage* wink_10 = [self getResourcePNG:@"wink_10"];
    UIImage* wink_11 = [self getResourcePNG:@"wink_11"];
    UIImage* wink_12 = [self getResourcePNG:@"wink_12"];
    UIImage* wink_13 = [self getResourcePNG:@"wink_13"];
    UIImage* wink_14 = [self getResourcePNG:@"wink_14"];
    UIImage* wink_15 = [self getResourcePNG:@"wink_15"];
    UIImage* wink_16 = [self getResourcePNG:@"wink_16"];
    UIImage* wink_17 = [self getResourcePNG:@"wink_17"];
    UIImage* wink_18 = [self getResourcePNG:@"wink_18"];
    UIImage* wink_19 = [self getResourcePNG:@"wink_19"];
    UIImage* wink_20 = [self getResourcePNG:@"wink_20"];
    UIImage* wink_21 = [self getResourcePNG:@"wink_21"];
    UIImage* wink_22 = [self getResourcePNG:@"wink_22"];
    UIImage* wink_23 = [self getResourcePNG:@"wink_23"];
    UIImage* wink_24 = [self getResourcePNG:@"wink_24"];
    UIImage* wink_25 = [self getResourcePNG:@"wink_25"];
    UIImage* wink_26 = [self getResourcePNG:@"wink_26"];
    
    self.snapAnimationView.image = wink_26;
    
    self.snapAnimationView.animationImages = @[wink_10, wink_11, wink_12, wink_13, wink_14, wink_15,
                                               wink_16, wink_17, wink_18, wink_19, wink_20, wink_21,
                                               wink_22, wink_23, wink_24, wink_25, wink_26];
    
    self.snapAnimationView.animationRepeatCount = 1;
    self.snapAnimationView.animationDuration = 1.0;
    [self.snapAnimationView setHidden:NO];
    [self.snapAnimationView startAnimating];
}

- (void)hideAllUIElements
{
    self.torchButton.hidden = YES;
    self.torchLabel.hidden = YES;
    self.cancelButton.hidden = YES;
    self.helpButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.jobTitleLabel.hidden = YES;
    self.successLabel.hidden = YES;
    self.successImageView.hidden = YES;
    self.bottomBarImageView.hidden = YES;
    self.topBarImageView.hidden = YES;
    self.ghostImageView.hidden = YES;
}

- (void)hideUIElementsOnSuccessfulCapture
{
    self.torchButton.hidden = YES;
    self.torchLabel.hidden = YES;
    self.cancelButton.hidden = YES;
    self.helpButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.jobTitleLabel.hidden = YES;
}

- (void)showHint:(NSString *)hintString
{
    if (self.isFirstTimeHint)
    {
        self.isFirstTimeHint = NO;
        self.firstHintTime = [NSDate date];
    }
    
    if (self.isShowingHint)
    {
        return;
    }
    // Don't show bubbles when showing smart hint which has priority
    if (self.isShowingSmartHint)
    {
        //NSLog(@"UX2: showHint return due to isShowingSmartHint");
        return;
    }
// Hint is now valid again in v4.4
//    if ([hintString isEqualToString:kMiSnapHintNothingDetected])
//    {
//        return;
//    }
    
    self.hintView = nil;     // Force an unload

    NSString *messageKey = @"Not Defined";
    
    if ([self.params[kMiSnapDocumentType] hasPrefix:kMiSnapDocumentTypeDriverLicense])
    {
        //////////////////////////
        // Driver License messages
        //////////////////////////
        if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            // Generic
            messageKey = @"more_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            messageKey = @"less_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            messageKey = @"hold_center_license";
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            messageKey = @"hold_center_license";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            messageKey = @"too_close_license";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            messageKey = @"get_close_license";
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            messageKey = @"hold_steady";
        }
        else if ([hintString isEqualToString:kMiSnapHintHoldSteady])
        {
            messageKey = @"hold_steady";
        }
    }
    else  if ([self.params[kMiSnapDocumentType] hasPrefix:kMiSnapDocumentTypePassport])
    {
        ////////////////////
        // Passport messages
        ////////////////////
        if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            messageKey = @"more_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            messageKey = @"less_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            messageKey = @"hold_center_passport";
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            messageKey = @"hold_center_passport";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            messageKey = @"too_close_passport";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            messageKey = @"get_close_passport";
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            messageKey = @"hold_steady";
        }
        else if ([hintString isEqualToString:kMiSnapHintHoldSteady])
        {
            messageKey = @"hold_steady";
        }
    }
    else  if ([self.params[kMiSnapDocumentType] hasPrefix:kMiSnapDocumentTypeACH] ||
              [self.params[kMiSnapDocumentType] hasPrefix:kMiSnapDocumentTypeCheckFront] ||
              [self.params[kMiSnapDocumentType] hasPrefix:kMiSnapDocumentTypeCheckBack])
    {
        ////////////////////
        // Check messages
        ////////////////////
        if ([hintString isEqualToString:kMiSnapHintGoodFrame])
        {
            messageKey = @"good_frame";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            messageKey = @"more_light";
            self.hintView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"misnap_en_check_hint_too_dark"]];
            [self animateHint:self.hintView];
            //[self.parentViewController.uxpEventMgr addEvent:UXP_BRIGHTNESS_HELP];
            [self sayText:@"more_light"];
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            messageKey = @"less_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            messageKey = @"hold_center_check";
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            messageKey = @"hold_center_check";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            messageKey = @"too_close_check";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            messageKey = @"get_close_check";
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            messageKey = @"hold_steady";
        }
        else if ([hintString isEqualToString:kMiSnapHintHoldSteady])
        {
            messageKey = @"hold_steady";
        }
    }
    else
    {
        ////////////////////
        // Generic messages
        ////////////////////
        if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            messageKey = @"more_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            messageKey = @"less_light";
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            messageKey = @"hold_center";
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            messageKey = @"hold_center";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            messageKey = @"too_close";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            messageKey = @"get_close";
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            messageKey = @"hold_steady";
        }
        else if ([hintString isEqualToString:kMiSnapHintHoldSteady])
        {
            messageKey = @"hold_steady";
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            messageKey = @"less_light";
        }
    }
    
    float width = 320;
    /// Add more height for nothing detected hint
    float height = [hintString isEqualToString:kMiSnapHintNothingDetected]?130:100;
    float originX = (self.bounds.size.width - width) / 2;
    float originY = (self.bounds.size.height - height) / 2;
    CGRect hintRect = CGRectMake(originX, originY, width, height);
    
    self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
    self.smartHint.tag = 12345;
    [self.smartHint setTitle:[self.resourceLocator getLocalizedString:messageKey] forState:UIControlStateNormal];
    self.smartHint.enabled = NO;
    // Following values are configurable. Set in initializeObjects method
    [self.smartHint setTitleColor:self.smartHintTextColor forState:UIControlStateNormal];
    self.smartHint.titleLabel.font = self.smartHintFont;
    self.smartHint.backgroundColor = self.smartHintBackgroundColor;
    [[self.smartHint layer] setBorderWidth:self.smartHintBorderWidth];
    [[self.smartHint layer] setBorderColor:self.smartHintBorderColor.CGColor];
    [[self.smartHint layer] setCornerRadius:self.smartHintCornerRadius];
    
    NSDate *currentTime = [NSDate new];
    NSTimeInterval timeSinceFirstHint = [currentTime timeIntervalSinceDate:self.firstHintTime];
    
    if (timeSinceFirstHint < self.firstHintDelayTime)
    {
        return;
    }
    
    [self animateSmartHint:self.smartHint];
    [self sayText:messageKey];
    
    // Let nothing detected hint span 3 lines
    self.smartHint.titleLabel.numberOfLines = ([hintString isEqualToString:kMiSnapHintNothingDetected]?3:2);
    self.smartHint.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.smartHint.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.smartHint.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect
{
    if (self.isFirstTimeHint)
    {
        self.isFirstTimeHint = NO;
        self.firstHintTime = [NSDate date];
    }
    
    NSLog(@"MOV2 showSmartHint %@ isShowingSmartHint %d", hintString, self.isShowingSmartHint);
    if (self.isShowingSmartHint) {
        return;
    }
    
    if ([hintString isEqualToString:kMiSnapHintNotCheckBack] && self.shouldShowSmartHintNotCheckBack == FALSE) {
        return;
    }
    else if ([hintString isEqualToString:kMiSnapHintNotCheckFront] && self.shouldShowSmartHintNotCheckFront == FALSE) {
        return;
    }
    else if ([hintString isEqualToString:kMiSnapHintLowContrast] && self.shouldShowSmartHintLowContrast == FALSE) {
        return;
    }
    else if ([hintString isEqualToString:kMiSnapHintBusyBackground] && self.shouldShowSmartHintBusyBackground == FALSE) {
        return;
    }
// Nothing detected hint is valid in v4.4
//    else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
//    {
//        return;
//    }
    
    self.smartHint = nil;     // Force an unload
    NSString *hintMessage = nil;
    
    float width = 320;
    // Add more height for nothing detected hint
    float height = [hintString isEqualToString:kMiSnapHintNothingDetected]?130:100;
    float originX = (self.bounds.size.width - width) / 2;
    float originY = (self.bounds.size.height - height) / 2;
    CGRect hintRect = CGRectMake(originX, originY, width, height);

    if ([hintString isEqualToString:kMiSnapHintGlare])
    {
        self.smartGlareBox = [[UIButton alloc] initWithFrame:boundingRect];
        self.smartGlareBox.tag = 123456;
        self.smartGlareBox.enabled = NO;
        self.smartGlareBox.hidden = NO;
        // Following values are configurable. Set in initializeObjects method
        self.smartGlareBox.backgroundColor = self.glareBoxBackgroundColor;
        [[self.smartGlareBox layer] setBorderWidth:self.glareBoxBorderWidth];
        [[self.smartGlareBox layer] setBorderColor:self.glareBoxBorderColor.CGColor];
        [[self.smartGlareBox layer] setCornerRadius:self.glareBoxCornerRadius];
        
        hintMessage = @"reduce_glare";

        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
        NSDate *currentTime = [NSDate new];
        NSTimeInterval timeSinceFirstHint = [currentTime timeIntervalSinceDate:self.firstHintTime];
        
        if (timeSinceFirstHint < self.firstHintDelayTime)
        {
            return;
        }
        
        if (self.shouldShowSmartHintGlare == YES && self.showGlareTracking == YES) {
            [self animateSmartHint:self.smartHint withGlareBox:self.smartGlareBox];
        }
        else if (self.shouldShowSmartHintGlare == YES) {
            [self animateSmartHint:self.smartHint];
        }
        else if (self.showGlareTracking == YES) {
            [self animateSmartHint:self.smartGlareBox];
        }
        
        [self sayText:hintMessage];
    }
    else if ([hintString isEqualToString:kMiSnapHintNotCheckBack] && self.shouldShowSmartHintNotCheckBack)
    {
        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        hintMessage = @"not_check_back";
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
    }
    else if ([hintString isEqualToString:kMiSnapHintNotCheckFront] && self.shouldShowSmartHintNotCheckFront)
    {
        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        hintMessage = @"not_check_front";
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
    }
    else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
    {
        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        hintMessage = @"nothing_detected";
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
    }
    else if ([hintString isEqualToString:kMiSnapHintLowContrast] && self.shouldShowSmartHintLowContrast)
    {
        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        hintMessage = @"low_contrast";
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
    }
    else if ([hintString isEqualToString:kMiSnapHintBusyBackground] && self.shouldShowSmartHintBusyBackground)
    {
        self.smartHint = [[UIButton alloc] initWithFrame:hintRect];
        hintMessage = @"busy_background";
        [self.smartHint setTitle:[self.resourceLocator getLocalizedString:hintMessage] forState:UIControlStateNormal];
    }
    else
    {
        [self showHint:hintString];
        return;
    }
    
    NSDate *currentTime = [NSDate new];
    NSTimeInterval timeSinceFirstHint = [currentTime timeIntervalSinceDate:self.firstHintTime];
    
    if (timeSinceFirstHint < self.firstHintDelayTime)
    {
        return;
    }
    
    [self animateSmartHint:self.smartHint];
    [self sayText:hintMessage];

    // Let nothing detected hint span 3 lines
    self.smartHint.titleLabel.numberOfLines = ([hintString isEqualToString:kMiSnapHintNothingDetected]?3:2);
    self.smartHint.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.smartHint.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.smartHint.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.smartHint.tag = 12345;
    self.smartHint.enabled = NO;
    
    // Following values are configurable. Set in initializeObjects method
    [self.smartHint setTitleColor:self.smartHintTextColor forState:UIControlStateNormal];
    self.smartHint.titleLabel.font = self.smartHintFont;
    self.smartHint.backgroundColor = self.smartHintBackgroundColor;
    [[self.smartHint layer] setBorderWidth:self.smartHintBorderWidth];
    [[self.smartHint layer] setBorderColor:self.smartHintBorderColor.CGColor];
    [[self.smartHint layer] setCornerRadius:self.smartHintCornerRadius];
}

- (void)hideSmartHint
{
    self.smartHint.hidden = TRUE;
    self.smartGlareBox.hidden = TRUE;
}

- (void)hideHint
{
    self.hintView.hidden = TRUE;
}

- (void)drawBoxAndBounce:(CGRect)documentRectangle
{
}

@end
