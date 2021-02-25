//
//  MiSnapSDKOverlayViewUX1.m
//  MiSnapDevApp
//
//  Created by Steve Blake on 11/22/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import "MiSnapSDKOverlayViewUX1.h"
#import <MiSnapSDK/MiSnapSDK.h>

@interface MiSnapSDKOverlayViewUX1()

@property (nonatomic, strong) UIButton* smartHint;
@property (nonatomic, strong) NSTimer* smartHintTimer;

@property (nonatomic, strong) MiSnapSDKParameters* docCaptureParams;

@property (nonatomic, assign) NSInteger smartBubbleCounter;
@property (nonatomic, assign) CGFloat smartBubbleDelay;

@property (nonatomic, assign) CGFloat aspectRatio;

@property (nonatomic, strong) NSDate *firstHintTime;
@property (nonatomic, assign) BOOL isFirstTimeHint;
@property (nonatomic, assign) NSTimeInterval firstHintDelayTime;

@property (nonatomic, assign) BOOL gaugeIsOpen;
@property (nonatomic, assign) BOOL isShowingSmartBubble;
@property (nonatomic, assign) BOOL isShowingSmartHint;
@property (nonatomic, assign) int completionScore;

@property (nonatomic, assign) CGRect guideDotRect;

// Settings for SmartBox (glare box)
@property (nonatomic, strong) UIColor *glareBoxBackgroundColor;
@property (nonatomic, strong) UIColor *glareBoxBorderColor;
@property (nonatomic, assign) float glareBoxBorderWidth;
@property (nonatomic, assign) float glareBoxCornerRadius;

@end

@implementation MiSnapSDKOverlayViewUX1

@dynamic aspectRatio;
@dynamic ghostImageView;
@dynamic ghostTextLabel;
@dynamic jobTitleLabel;
@dynamic torchButton;
@dynamic snapButton;

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
    self.gaugeIsOpen = FALSE;
    self.isShowingSmartBubble = FALSE;
    self.isShowingSmartHint = FALSE;
    self.completionScore = 0;
    
    self.smartHintTimer = nil;
    
    self.jobTitleLabel.text = @"";

    self.glareBoxBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
    self.glareBoxBorderColor = [[UIColor redColor] colorWithAlphaComponent:0.9f];
    self.glareBoxBorderWidth = 6.0f;
    self.glareBoxCornerRadius = 8.0f;
    
    self.smartBubbleCounter = 0;
    
    CGFloat biggerSide = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
    CGFloat smallerSide = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
    
    self.aspectRatio = biggerSide / smallerSide;
    
    self.isFirstTimeHint = YES;
    
    // Set a small delay so the first hint won't appear to early (possibly with a wrong hint)
    self.firstHintDelayTime = 2.0;
}

- (void)sayText:(NSString *)textStr
{
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];
    //NSString *localizedStr = [resourceLocator getLocalizedString:textStr];
    //NSLog(@"UX1 sayText textStr %@ localizedStr %@", textStr, localizedStr);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [resourceLocator getLocalizedString:textStr]);
}

#pragma mark - Animation

- (void)animateBubble
{
    CGFloat bottomOffset = -10.0;
    CGFloat leftOffset = (self.gaugeImageView.frame.size.width * self.completionScore) / (100 + 6); // Add 6 so bubble won't be right of gauge
    CGFloat bubbleHeight = 120.0;
    CGFloat bubbleWidth = 96.0;
    
    //NSLog(@"gaugeImageView Origin = %@", NSStringFromCGPoint(self.gaugeImageView.frame.origin));
    CGFloat bottomPoint  = self.gaugeImageView.frame.origin.y + bottomOffset;
    CGFloat leftPoint  = self.gaugeImageView.frame.origin.x + leftOffset + self.gaugeImageView.frame.size.width * 0.04;
    
    // put the error bubble at the spot where the gauge is (0-100%)
    // and them animate it up, hold it, then have it animate away
    [self.smartBubbleImageView setBounds:CGRectMake(leftPoint, bottomPoint, 10.0, 10.0)];
    [self.smartBubbleImageView.layer setAnchorPoint:CGPointMake(0.5, 1.0)];
    [self.smartBubbleImageView setFrame:CGRectMake(leftPoint, bottomPoint, 10.0, 10.0)];
    
    [self.smartBubbleLabel setBounds:CGRectMake(leftPoint, bottomPoint, bubbleWidth - 7, bubbleHeight)];
    [self.smartBubbleLabel.layer setAnchorPoint:CGPointMake(0.5, 1.0)];
    [self.smartBubbleLabel setFrame:CGRectMake(leftPoint, bottomPoint, bubbleWidth - 7, bubbleHeight)];
    
    self.smartBubbleImageView.hidden = NO;
    self.smartBubbleImageView.alpha = 1.0;
    
    self.smartBubbleLabel.hidden = NO;
    self.smartBubbleLabel.alpha = 0.0;
    
    self.smartHint.alpha = 1.0;
    
    self.isShowingSmartHint = TRUE;
    self.isShowingSmartBubble = TRUE;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [self.smartBubbleImageView setBounds:CGRectMake(leftPoint, bottomPoint, bubbleWidth, bubbleHeight)];
                         
                     } completion:^(BOOL finished) {
                         
                         self.smartBubbleLabel.center = self.smartBubbleImageView.center;
                         
                         [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             
                             self.smartBubbleLabel.alpha = 1.0;
                             
                         } completion:nil];
                         
                         [UIView animateWithDuration:0.15 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             
                             self.smartBubbleLabel.alpha = 0.0;
                             
                         } completion:nil];
                         
                         [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                             
                             [self.smartBubbleImageView setBounds:CGRectMake(leftPoint, bottomPoint, 0.0, 0.0)];
                             self.smartBubbleLabel.alpha = 0.0;
                             self.smartBubbleLabel.center = self.smartBubbleImageView.center;
                             
                         } completion:^(BOOL finished) {
                             
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.smartBubbleDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 
                                 self.smartBubbleImageView.hidden = YES;
                                 self.smartBubbleLabel.hidden = YES;
                                 
                                 self.isShowingSmartBubble = FALSE;
                                 self.isShowingSmartHint = FALSE;
                                 
                             });
                         }];
                     }];
}

#pragma mark - External methods

- (void)setupViewWithParams:(NSDictionary *)params;
{
    self.docCaptureParams = [MiSnapSDKParameters new];
    [self.docCaptureParams updateParameters:params];

    self.ghostImageView.hidden = YES;
    self.ghostImageView.alpha = 1.0;
    self.ghostTextLabel.hidden = YES;

    self.gaugeImageView.hidden = YES;
    self.guideDotImageView.hidden = YES;
    self.snapAnimationView.hidden = YES;
    
    self.cancelButton.hidden = NO;
    self.helpButton.hidden = NO;
    self.jobTitleLabel.hidden = NO;
    self.ghostTextLabel.hidden = NO;

    if (self.smartBubbleImageView != nil)
    {
        self.smartBubbleImageView.hidden = YES;
    }

    if (self.smartBubbleImageView != nil)
    {
        self.smartBubbleLabel.hidden = YES;
    }

    [self setupJobTitle];

    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];

    [self.cancelButton setAccessibilityLabel:[resourceLocator getLocalizedString:@"misnap_overlay_cancel_button"]];
    [self.snapButton   setAccessibilityLabel:[resourceLocator getLocalizedString:@"misnap_overlay_capture_button"]];
    [self.torchButton  setAccessibilityLabel:[resourceLocator getLocalizedString:@"misnap_overlay_flash_off"]];
    [self.helpButton   setAccessibilityLabel:[resourceLocator getLocalizedString:@"misnap_overlay_help_button"]];

    [self.helpButton setEnabled:YES];

    /////////////////////////////////////////////////////////////////////////////
    // WARNING: Do not comment out this if statement to make the snapButton
    //          appear and be enabled.  To display an enabled manual button,
    //          go to the MiSnapViewControllerUX1 showMiSnap method and follow
    //          the instructions in the comments
    /////////////////////////////////////////////////////////////////////////////
    if ((self.docCaptureParams.captureMode == MiSnapCaptureModeManual)
        || (self.docCaptureParams.captureMode == MiSnapCaptureModeManualAssist)
        || (self.docCaptureParams.captureMode == MiSnapCaptureModeHighResManual))
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

    [self setGhostImage:self.docCaptureParams.documentType withOrientation:[UIApplication sharedApplication].statusBarOrientation];

    CGRect newFrame = self.guideDotImageView.frame;
    newFrame.origin = CGPointMake(-100, -100);
    self.guideDotImageView.frame = newFrame; // Force it offscreen

    UIImage *torchImage;
    NSString *torchAccessibilityLabel;

    if (self.docCaptureParams.torchMode == 0)
    {
        torchImage = [self getResourcePNG:@"icon_flash_off"];
        torchAccessibilityLabel = [resourceLocator getLocalizedString:@"misnap_overlay_flash_off"];
    }
    else if (self.docCaptureParams.torchMode == 1)
    {
        torchImage = [self getResourcePNG:@"icon_flash_on"];
        torchAccessibilityLabel = [resourceLocator getLocalizedString:@"misnap_overlay_flash_on"];
    }
    else if (self.docCaptureParams.torchMode == 2)
    {
        torchImage = [self getResourcePNG:@"icon_flash_on"];
        torchAccessibilityLabel = [resourceLocator getLocalizedString:@"misnap_overlay_flash_auto"];
    }

    [self.torchButton setBackgroundImage:torchImage forState:UIControlStateNormal];
    [self.torchButton setAccessibilityLabel:torchAccessibilityLabel];
    
    if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        self.torchButton.hidden = YES;
    }
    else
    {
        self.torchButton.hidden = NO;
    }

    [self performSelector:@selector(sayText:) withObject:self.ghostImageView.accessibilityLabel afterDelay:2.0];

    self.smartBubbleDelay = self.docCaptureParams.smartHintUpdatePeriod / 1000.0 < 2.0 ? 0.0 : self.docCaptureParams.smartHintUpdatePeriod / 1000.0 - 2.0;
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

- (void)setTorchButtonStatus:(BOOL)onFlag
{
    UIImage* image;
    NSString* accessibilityLabel;
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];
    
    if (onFlag == YES)
    {
        image = [self getResourcePNG:@"icon_flash_on"];
        accessibilityLabel = [resourceLocator getLocalizedString:@"misnap_overlay_flash_on"];
    }
    else
    {
        image = [self getResourcePNG:@"icon_flash_off"];
        accessibilityLabel = [resourceLocator getLocalizedString:@"misnap_overlay_flash_off"];
    }
    
    [self.torchButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.torchButton setAccessibilityLabel:accessibilityLabel];
}

- (void)openGaugeImageView
{
    if (self.gaugeIsOpen == TRUE)
        return;
    
    self.gaugeIsOpen = TRUE;
    
    UIImage* gauge_open_01 = [self getResourcePNG:@"gauge_open_01"];
    UIImage* gauge_open_02 = [self getResourcePNG:@"gauge_open_02"];
    UIImage* gauge_open_03 = [self getResourcePNG:@"gauge_open_03"];
    UIImage* gauge_open_04 = [self getResourcePNG:@"gauge_open_04"];
    UIImage* gauge_open_05 = [self getResourcePNG:@"gauge_open_05"];
    UIImage* gauge_open_06 = [self getResourcePNG:@"gauge_open_06"];
    UIImage* gauge_open_07 = [self getResourcePNG:@"gauge_open_07"];
    UIImage* gauge_open_08 = [self getResourcePNG:@"gauge_open_08"];
    UIImage* gauge_open_09 = [self getResourcePNG:@"gauge_open_09"];
    UIImage* gauge_open_10 = [self getResourcePNG:@"gauge_open_10"];
    UIImage* gauge_open_11 = [self getResourcePNG:@"gauge_open_11"];
    UIImage* gauge_open_12 = [self getResourcePNG:@"gauge_open_12"];
    UIImage* gauge_open_13 = [self getResourcePNG:@"gauge_open_13"];
    UIImage* gauge_open_14 = [self getResourcePNG:@"gauge_open_14"];
    UIImage* gauge_open_15 = [self getResourcePNG:@"gauge_open_15"];
    UIImage* gauge_open_16 = [self getResourcePNG:@"gauge_open_16"];
    UIImage* gauge_open_17 = [self getResourcePNG:@"gauge_open_17"];
    UIImage* gauge_open_18 = [self getResourcePNG:@"gauge_open_18"];
    UIImage* gauge_open_19 = [self getResourcePNG:@"gauge_open_19"];
    UIImage* gauge_open_20 = [self getResourcePNG:@"gauge_open_20"];
    UIImage* gauge_open_21 = [self getResourcePNG:@"gauge_open_21"];
    UIImage* gauge_open_22 = [self getResourcePNG:@"gauge_open_22"];
    UIImage* gauge_open_23 = [self getResourcePNG:@"gauge_open_23"];
    
    self.gaugeImageView.animationImages = @[gauge_open_01, gauge_open_02, gauge_open_03, gauge_open_04,
                                            gauge_open_05, gauge_open_06, gauge_open_07, gauge_open_08,
                                            gauge_open_09, gauge_open_10, gauge_open_11, gauge_open_12,
                                            gauge_open_13, gauge_open_14, gauge_open_15, gauge_open_16,
                                            gauge_open_17, gauge_open_18, gauge_open_19, gauge_open_20,
                                            gauge_open_21, gauge_open_22, gauge_open_23, gauge_open_23];
    
    self.gaugeImageView.animationRepeatCount = 1;
    
    self.gaugeImageView.hidden = NO;
    [self.gaugeImageView setNeedsLayout];
    [self.gaugeImageView startAnimating];
}

- (void)closeGaugeImageView
{
    if (self.gaugeIsOpen == FALSE)
        return;
    
    self.gaugeIsOpen = FALSE;
    
    UIImage* gauge_open_01 = [self getResourcePNG:@"gauge_open_01"];
    UIImage* gauge_open_02 = [self getResourcePNG:@"gauge_open_02"];
    UIImage* gauge_open_03 = [self getResourcePNG:@"gauge_open_03"];
    UIImage* gauge_open_04 = [self getResourcePNG:@"gauge_open_04"];
    UIImage* gauge_open_05 = [self getResourcePNG:@"gauge_open_05"];
    UIImage* gauge_open_06 = [self getResourcePNG:@"gauge_open_06"];
    UIImage* gauge_open_07 = [self getResourcePNG:@"gauge_open_07"];
    UIImage* gauge_open_08 = [self getResourcePNG:@"gauge_open_08"];
    UIImage* gauge_open_09 = [self getResourcePNG:@"gauge_open_09"];
    UIImage* gauge_open_10 = [self getResourcePNG:@"gauge_open_10"];
    UIImage* gauge_open_11 = [self getResourcePNG:@"gauge_open_11"];
    UIImage* gauge_open_12 = [self getResourcePNG:@"gauge_open_12"];
    UIImage* gauge_open_13 = [self getResourcePNG:@"gauge_open_13"];
    UIImage* gauge_open_14 = [self getResourcePNG:@"gauge_open_14"];
    UIImage* gauge_open_15 = [self getResourcePNG:@"gauge_open_15"];
    UIImage* gauge_open_16 = [self getResourcePNG:@"gauge_open_16"];
    UIImage* gauge_open_17 = [self getResourcePNG:@"gauge_open_17"];
    UIImage* gauge_open_18 = [self getResourcePNG:@"gauge_open_18"];
    UIImage* gauge_open_19 = [self getResourcePNG:@"gauge_open_19"];
    UIImage* gauge_open_20 = [self getResourcePNG:@"gauge_open_20"];
    UIImage* gauge_open_21 = [self getResourcePNG:@"gauge_open_21"];
    UIImage* gauge_open_22 = [self getResourcePNG:@"gauge_open_22"];
    UIImage* gauge_open_23 = [self getResourcePNG:@"gauge_open_23"];
    
    self.gaugeImageView.animationImages = @[gauge_open_23, gauge_open_23, gauge_open_22, gauge_open_21,
                                            gauge_open_20, gauge_open_19, gauge_open_18, gauge_open_17,
                                            gauge_open_16, gauge_open_15, gauge_open_14, gauge_open_13,
                                            gauge_open_12, gauge_open_11, gauge_open_10, gauge_open_09,
                                            gauge_open_08, gauge_open_07, gauge_open_06, gauge_open_05,
                                            gauge_open_04, gauge_open_03, gauge_open_02, gauge_open_01];
    
    self.gaugeImageView.animationRepeatCount = 1;
    [self.gaugeImageView setNeedsLayout];
    self.gaugeImageView.image = nil;
    [self.gaugeImageView startAnimating];
}

- (void)updateGaugeValue:(int)fillPercentage
{
    self.completionScore = fillPercentage;
    
    int imageIndex = (fillPercentage / 5) * 5;
    
    NSString* filename = [NSString stringWithFormat:@"gauge_fill_%02d", imageIndex];
    self.gaugeImageView.image = [self getResourcePNG:filename];
    self.gaugeImageView.hidden = NO;
    [self.gaugeImageView setNeedsLayout];
}

- (void)runSnapAnimation
{
    UIImage* bug_01 = [self getResourcePNG:@"bug_animation_01"];
    UIImage* bug_02 = [self getResourcePNG:@"bug_animation_02"];
    UIImage* bug_03 = [self getResourcePNG:@"bug_animation_03"];
    UIImage* bug_04 = [self getResourcePNG:@"bug_animation_04"];
    UIImage* bug_05 = [self getResourcePNG:@"bug_animation_05"];
    UIImage* bug_06 = [self getResourcePNG:@"bug_animation_06"];
    UIImage* bug_07 = [self getResourcePNG:@"bug_animation_07"];
    UIImage* bug_08 = [self getResourcePNG:@"bug_animation_08"];
    UIImage* bug_09 = [self getResourcePNG:@"bug_animation_09"];
    UIImage* bug_10 = [self getResourcePNG:@"bug_animation_10"];
    UIImage* bug_11 = [self getResourcePNG:@"bug_animation_11"];
    UIImage* bug_12 = [self getResourcePNG:@"bug_animation_12"];
    UIImage* bug_13 = [self getResourcePNG:@"bug_animation_13"];
    UIImage* bug_14 = [self getResourcePNG:@"bug_animation_14"];
    UIImage* bug_15 = [self getResourcePNG:@"bug_animation_15"];
    UIImage* bug_16 = [self getResourcePNG:@"bug_animation_16"];
    UIImage* bug_17 = [self getResourcePNG:@"bug_animation_17"];
    UIImage* bug_18 = [self getResourcePNG:@"bug_animation_18"];
    UIImage* bug_19 = [self getResourcePNG:@"bug_animation_19"];
    UIImage* bug_20 = [self getResourcePNG:@"bug_animation_20"];
    UIImage* bug_21 = [self getResourcePNG:@"bug_animation_21"];
    UIImage* bug_22 = [self getResourcePNG:@"bug_animation_22"];
    UIImage* bug_23 = [self getResourcePNG:@"bug_animation_23"];
    UIImage* bug_24 = [self getResourcePNG:@"bug_animation_24"];
    UIImage* bug_25 = [self getResourcePNG:@"bug_animation_25"];
    UIImage* bug_26 = [self getResourcePNG:@"bug_animation_26"];
    UIImage* bug_27 = [self getResourcePNG:@"bug_animation_27"];
    UIImage* bug_28 = [self getResourcePNG:@"bug_animation_28"];
    UIImage* bug_29 = [self getResourcePNG:@"bug_animation_29"];
    UIImage* bug_30 = [self getResourcePNG:@"bug_animation_30"];
    UIImage* bug_31 = [self getResourcePNG:@"bug_animation_31"];
    UIImage* bug_32 = [self getResourcePNG:@"bug_animation_32"];
    UIImage* bug_33 = [self getResourcePNG:@"bug_animation_33"];
    UIImage* bug_34 = [self getResourcePNG:@"bug_animation_34"];
    UIImage* bug_35 = [self getResourcePNG:@"bug_animation_35"];
    UIImage* bug_36 = [self getResourcePNG:@"bug_animation_36"];
    UIImage* bug_37 = [self getResourcePNG:@"bug_animation_37"];
    UIImage* bug_38 = [self getResourcePNG:@"bug_animation_38"];
    UIImage* bug_39 = [self getResourcePNG:@"bug_animation_39"];
    UIImage* bug_40 = [self getResourcePNG:@"bug_animation_40"];
    
    self.snapAnimationView.image = bug_40;
    
    self.snapAnimationView.animationImages = @[bug_01, bug_02, bug_03, bug_04, bug_05, bug_06, bug_07, bug_08, bug_09, bug_10,
                                               bug_11, bug_12, bug_13, bug_14, bug_15, bug_16, bug_17, bug_18, bug_19, bug_20,
                                               bug_21, bug_22, bug_23, bug_24, bug_25, bug_26, bug_27, bug_28, bug_29, bug_30,
                                               bug_31, bug_32, bug_33, bug_34, bug_35, bug_36, bug_37, bug_38, bug_39, bug_40];
    
    self.snapAnimationView.animationRepeatCount = 1;
    self.snapAnimationView.animationDuration = 2.0;
    [self.snapAnimationView setHidden:NO];
    [self.snapAnimationView startAnimating];
}

- (void)hideAllUIElements
{
    self.torchButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.helpButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.jobTitleLabel.hidden = YES;
    self.smartHint.hidden = YES;
    self.smartBubbleLabel.hidden = YES;
    self.smartBubbleImageView.hidden = YES;
    self.gaugeImageView.hidden = YES;
    self.snapAnimationView.hidden = YES;
    self.ghostImageView.hidden = YES;
    self.ghostTextLabel.hidden = YES;
}

- (void)hideUIElementsOnSuccessfulCapture
{
    self.torchButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.helpButton.hidden = YES;
    self.snapButton.hidden = YES;
    self.jobTitleLabel.hidden = YES;
}

- (void)animateHint:(UIView*)hintView
{
    [hintView setAlpha:0.0];
    [self addSubview:hintView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [hintView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5 delay:(self.docCaptureParams.smartHintUpdatePeriod / 1000.0 - 1.0) options:UIViewAnimationOptionCurveLinear animations:^{
                             [hintView setAlpha:0.0];
                         } completion:^(BOOL finished) {
                             [hintView removeFromSuperview];
                         }];
                     }];
}


- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect
{
    if (self.isFirstTimeHint)
    {
        self.isFirstTimeHint = NO;
        self.firstHintTime = [NSDate new];
    }
    
    //NSLog(@"UX1: showSmartHint >> hint %@ isShowingSmartBubble %d isShowingSmartHint %d", hintString, self.isShowingSmartBubble, self.isShowingSmartHint);
    if (self.isShowingSmartBubble) {
        //NSLog(@"UX1: showSmartHint return due to isShowingSmartBubble");
        return;
    }
    
    // Don't show bubbles when showing smart hint which has priority
    if (self.isShowingSmartHint) {
        //NSLog(@"UX1: showSmartHint return due to isShowingSmartHint");
        return;
    }
    
    // Don't show bubble first time too fast while a thermometer is still opening
    //    if (self.smartBubbleCounter < 5)
    //    {
    //        self.smartBubbleCounter++;
    //        return;
    //    }
    
    self.smartHint = nil;     // Force an unload
    
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];
    
    NSString *smartBubbleString = [NSString string];
    
    if ([hintString isEqualToString:kMiSnapHintGlare])
    {
        if (self.showGlareTracking == TRUE) {
            
            self.smartHint = [[UIButton alloc] initWithFrame:boundingRect];
            self.smartHint.enabled = NO;
            self.smartHint.backgroundColor = self.glareBoxBackgroundColor;
            [[self.smartHint layer] setBorderWidth:self.glareBoxBorderWidth];
            [[self.smartHint layer] setBorderColor:self.glareBoxBorderColor.CGColor];
            [[self.smartHint layer] setCornerRadius:self.glareBoxCornerRadius];
        }
        
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_reduce_glare"];
        smartBubbleString = @"reduce_glare";
    }
    else if ([hintString isEqualToString:kMiSnapHintGoodFrame])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_use_front_check"];
        smartBubbleString = @"good_frame";
    }
    else if ([hintString isEqualToString:kMiSnapHintNotCheckBack])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_flip_check"];
        smartBubbleString = @"not_check_back";
    }
    else if ([hintString isEqualToString:kMiSnapHintNotCheckFront])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_use_front_check"];
        smartBubbleString = @"not_check_front";
    }
    else if ([hintString isEqualToString:kMiSnapHintLowContrast])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_use_dark_background"];
        smartBubbleString = @"low_contrast";
    }
    else if ([hintString isEqualToString:kMiSnapHintBusyBackground])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_use_plain_background"];
        smartBubbleString = @"busy_background";
    }
    else if ([hintString isEqualToString:kMiSnapHintTooDim])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_more_light"];
        smartBubbleString = @"more_light";
    }
    else if ([hintString isEqualToString:kMiSnapHintTooBright])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_less_light"];
        smartBubbleString = @"less_light";
    }
    else if ([hintString isEqualToString:kMiSnapHintRotation])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_center"];
        smartBubbleString = @"hold_center";
    }
    else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_center"];
        smartBubbleString = @"hold_center";
    }
    else if ([hintString isEqualToString:kMiSnapHintTooClose])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_tooclose"];
        smartBubbleString = @"too_close";
    }
    else if ([hintString isEqualToString:kMiSnapHintNotSharp])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_hold_steady"];
        smartBubbleString = @"hold_steady";
    }
    else if ([hintString isEqualToString:kMiSnapHintTooFar])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_getcloser"];
        smartBubbleString = @"get_close";
    }
    else if ([hintString isEqualToString:kMiSnapHintTooBright])
    {
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_less_light"];
        smartBubbleString = @"less_light";
    }
    else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
    {
        //isShowingSmartBubble = FALSE;
        //isShowingSmartHint = FALSE;
        //return;
        self.smartBubbleImageView.image = [UIImage imageNamed:@"error_hold_steady"];
        smartBubbleString = @"nothing_detected";
        
    }
    else
    {
        //NSLog(@"showSmartHint should not get here!!!! message %@", smartBubbleString);
        self.isShowingSmartBubble = FALSE;
        self.isShowingSmartHint = FALSE;
        return;
    }
    
    NSDate *currentTime = [NSDate new];
    NSTimeInterval timeSinceFirstHint = [currentTime timeIntervalSinceDate:self.firstHintTime];
    
    if (timeSinceFirstHint < self.firstHintDelayTime)
    {
        return;
    }
    
    [self animateBubble];
    [self animateHint:self.smartHint];
    [self sayText:smartBubbleString];
    self.smartBubbleLabel.text = [resourceLocator getLocalizedString:smartBubbleString];
}

- (void)hideSmartHint
{
    self.smartBubbleImageView.alpha = 0.0;
    self.smartBubbleLabel.alpha = 0.0;
    self.smartBubbleLabel.hidden = TRUE;
}

- (void)hideHint
{
    self.smartHint.alpha = 0.0;
    self.smartHint.hidden = TRUE;
}

- (void)drawBoxAndBounce:(CGRect)documentRectangle
{
    // Draw rectangle
    self.objectRectangleView.frame = CGRectMake(documentRectangle.origin.x, documentRectangle.origin.y, documentRectangle.size.width, documentRectangle.size.height);
    self.objectRectangleView.hidden = NO;
    
    
    self.objectRectangleView.layer.borderWidth = (self.docCaptureParams.animationRectangleStrokeWidth / 2.0);
    self.objectRectangleView.layer.cornerRadius = self.docCaptureParams.animationRectangleCornerRadius;
    self.objectRectangleView.layer.borderColor = self.docCaptureParams.animationRectangleColor.CGColor;
    
    // bounce it
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         [UIView setAnimationRepeatCount:1.0];
                         [self.objectRectangleView setTransform:CGAffineTransformMakeScale(1.05, 1.05)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.333
                                               delay:0.3
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              self.objectRectangleView.alpha = 0;
                                          }
                                          completion:^(BOOL finished) {
                                              self.objectRectangleView.hidden = YES;
                                              self.objectRectangleView.alpha = 1;
                                          }];
                     }];
}

@end

