//
//  MiSnapCaptureViewController.m
//  MiSnap
//
//  Created by Greg Fisch on 1/28/15.
//  Copyright (c) 2015 mitek. All rights reserved.
//

#import <MiSnapSDK/MiSnapSDK.h>
#import <MiSnapSDKCamera/MiSnapSDKCamera.h>

#import "MiSnapSDKViewController.h"
#import "MiSnapSDKOverlayView.h"
#import "MiSnapSDKTutorialViewController.h"

#define TUTORIAL_STATE              0
#define CAPTURE_STATE               1
#define HELP_STATE                  2
#define FAILOVER_CAPTURE_STATE      3
#define NORMAL_COMPLETION_STATE     4
#define CANCEL_STATE                5

@interface MiSnapSDKViewController () <MiSnapCaptureViewDelegate, MiSnapTutorialViewControllerDelegate, MiSnapSDKCameraDelegate>

@property (nonatomic, weak) IBOutlet MiSnapSDKCamera *cameraView;
@property (nonatomic, weak) IBOutlet MiSnapSDKCaptureView *captureView;
@property (nonatomic, weak) IBOutlet MiSnapSDKOverlayView *overlayView;
@property (nonatomic, strong) MiSnapSDKTutorialViewController *helpViewController;

@property (nonatomic) UIInterfaceOrientation statusbarOrientation;

@property (nonatomic, strong) NSMutableDictionary *captureParams;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIVisualEffectView *sessionInterruptionView;
@property (nonatomic, assign) BOOL sessionIsInterrupted;
@property (nonatomic, strong) UILabel *sessionInterruptionLabel;
@property (nonatomic, assign) BOOL firstTimeTutorialHasBeenShown;
@property (nonatomic, assign) BOOL tutorialCancelled;
@property (nonatomic, assign) BOOL shouldSkipFrames;
@property (nonatomic, assign) BOOL imageCaptured;

@property (nonatomic, assign) UIDeviceOrientation oldOrientation;

@property (nonatomic, assign) BOOL torchWasON;
@property (nonatomic, assign) BOOL isFailover;
@property (nonatomic, assign) BOOL gaugeIsShowing;
@property (nonatomic, assign) BOOL timeoutDidOccur;

@property (nonatomic, assign) int timeoutCount;

@property (nonatomic, strong) NSString *initialCaptureMode;
@property (nonatomic) float analyzeFrameDelay;

@property (nonatomic, strong) NSArray *timeoutResults;

- (IBAction)helpButtonAction:(id)sender;
- (IBAction)torchButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)snapButtonAction:(id)sender;

@end

@implementation MiSnapSDKViewController

#pragma mark - View Lifecycle methods

- (void)initializeObjects
{
    self.shouldDissmissOnSuccess = TRUE; // The default
    self.showHintsInManualMode = FALSE;
    self.torchWasON = FALSE;
    self.isFailover = FALSE;
    self.gaugeIsShowing = FALSE;
    self.timeoutDidOccur = FALSE;
    self.shouldSkipFrames = FALSE; // Default is to analyze without skipping

    self.helpViewController = nil;
    self.showGlareTracking = TRUE; // Initialized TRUE. Set property where MiSnapSDKViewController is created to override.
    
    self.timeoutCount = 0;
    self.timeoutResults = nil;
    
    self.initialCaptureMode = nil;
    self.analyzeFrameDelay = 1.0f;  // The default is 1 second delay
    
    // Reference another MiSnapOverlayView object here to merely fix an iOS Linker issue not finding the real overlay view.
    // Without this, the real overlayView object appears to be a UIView, not a MiSnapOverlayView.
    // This causes a crash when the overlayView is sent methods that were meant for a MiSnapOverlayView, but not supported
    // by a standard UIView.
    [MiSnapSDKOverlayView class];
    
    self.useBarcodeScannerLight = YES;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initializeObjects];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initializeObjects];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.overlayView.alpha = 0.0;
    self.captureView.alpha = 0.0;
    self.captureView.delegate = self;
    self.cameraView.alpha = 0.0;
    self.orientationMode = (MiSnapOrientationMode)[self.captureParams[kMiSnapOrientationMode] integerValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.navigationController)
    {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.tutorialCancelled) { return; }
    
    [super viewDidAppear:animated];
    
    self.oldOrientation = UIDeviceOrientationUnknown;
    
    #if !TARGET_IPHONE_SIMULATOR
    if (! self.cameraView.sessionPreset)
    {
        if (self.orientationMode == MiSnapOrientationModeDeviceLandscapeGhostLandscape && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
        {
            self.cameraView.cameraOrientation = UIInterfaceOrientationLandscapeRight;
        }
        else
        {
            self.cameraView.cameraOrientation = self.statusbarOrientation;
        }
        [self.cameraView setSessionPreset:AVCaptureSessionPreset1920x1080 pixelBufferFormat:kCVPixelFormatType_32BGRA];
        
        if ([self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack] && self.useBarcodeScannerLight)
        {
            self.cameraView.detectPDF417 = YES;
        }

        self.cameraView.delegate = self;
    }
    else
    {
        [self didFinishConfiguringSession];
    }
    #else
        [self.cameraView setImage:[UIImage imageNamed:self.captureParams[@"InjectImageName"]] frameRate:4];
        self.cameraView.delegate = self;
        [self didFinishConfiguringSession];
    #endif
}

- (void)checkIfSplitScreen
{
    CGSize bounds = self.view.bounds.size;
    
    CGFloat biggerSide = bounds.width > bounds.height ? bounds.width : bounds.height;
    CGFloat smallerSide = bounds.width > bounds.height ? bounds.height : bounds.width;
    
    CGFloat aspectRatio = biggerSide / smallerSide;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (aspectRatio > 2 || aspectRatio < 1.2))
    {
        [self.view addSubview:self.sessionInterruptionView];
        [self.view addSubview:self.sessionInterruptionLabel];
        self.sessionIsInterrupted = YES;
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
    
    if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps)
    {
        if (![self.sessionInterruptionView isDescendantOfView:self.view])
        {
            [self.view addSubview:self.sessionInterruptionView];
            [self.view addSubview:self.sessionInterruptionLabel];
        }
        
        self.sessionIsInterrupted = YES;
    }
    else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableInBackground)
    {
        [self.cameraView turnTorchOff];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    NSLog(@"Session interruption ended");
    [self.sessionInterruptionView removeFromSuperview];
    [self.sessionInterruptionLabel removeFromSuperview];
    
    self.sessionIsInterrupted = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.captureView shutdown];
        
    self.sessionInterruptionView = nil;
    self.sessionInterruptionLabel = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View orientation methods

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
    
    [self.overlayView hideSmartHint];
    [self.overlayView hideHint];
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat biggerSide = width > height ? width : height;
    CGFloat smallerSide = width > height ? height : width;
    
    if (biggerSide / smallerSide > 1.32 && biggerSide / smallerSide < 1.34)
    {
        [self.sessionInterruptionView removeFromSuperview];
        [self.sessionInterruptionLabel removeFromSuperview];
    }
    
    self.sessionInterruptionView.frame = CGRectMake(0, 0, width, height);
    self.sessionInterruptionLabel.frame = CGRectMake(0, 0, width, height);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context)
    {
        self.statusbarOrientation = [UIApplication sharedApplication].statusBarOrientation;

        [self.captureView updateOrientation:self.statusbarOrientation];
        
        if (self.orientationMode == MiSnapOrientationModeDeviceLandscapeGhostLandscape && UIInterfaceOrientationIsPortrait(self.statusbarOrientation))
        {
            self.cameraView.cameraOrientation = UIInterfaceOrientationLandscapeRight;
        }
        else
        {
            self.cameraView.cameraOrientation = self.statusbarOrientation;
        }
        [self.cameraView updatePreviewLayer:self.statusbarOrientation];
        
        if (!self.imageCaptured)
        {
            [self.overlayView updateSnapButtonLocation];
            [self.overlayView setGhostImage:self.captureParams[kMiSnapDocumentType] withOrientation:self.statusbarOrientation];
        }
    }
    completion:nil];
}

#pragma mark - View Controller State Machine

- (void)runStateMachineAt:(int)newState
{
    NSTimeInterval timeoutValue, terminationDelay;
    
    [self stopTimer];
    
    __weak MiSnapSDKViewController* wself = self;
    
    int captureMode = [self.captureParams[kMiSnapCaptureMode] intValue];
    
    switch (newState)
    {
        case TUTORIAL_STATE:
            [self showTutorialView];
            break;
            
        case CAPTURE_STATE: // 1
            if ((captureMode != MiSnapCaptureModeManual)
                && (captureMode != MiSnapCaptureModeManualAssist)
                && (captureMode != MiSnapCaptureModeHighResManual))
            {
                timeoutValue = [self.captureParams[kMiSnapTimeout] integerValue];
                [self startTimer:timeoutValue];
            }
            // Reset timeoutDidOccur to FALSE so autocapture will work multiple times
            self.timeoutDidOccur = FALSE;
            [self showMiSnap];
            break;
            
        case HELP_STATE: // 2
            if ([self.captureParams[kMiSnapSeamlessFailover] boolValue])
            {
                [self showSeamlessFailover];
            }
            else
            {
                if (captureMode == MiSnapCaptureModeHighRes)    // Special hi-res mode)
                {
                    [self.captureParams setValue:@"6" forKey:kMiSnapCaptureMode];
                }
                else
                {
                    [self.captureParams setValue:@"1" forKey:kMiSnapCaptureMode];
                }
                [self showSmartTutorialWithNumberOfButtons:3 forDocumentType:self.captureParams[kMiSnapDocumentType] forTutorialMode:MiSnapTutorialModeFailover];
            }
            break;
            
        case FAILOVER_CAPTURE_STATE: // 3
            // Reset timeoutDidOccur to FALSE so the MiSnapCaptureViewDelegate methods will work upon manual capture
            self.timeoutDidOccur = FALSE;
            [self showMiSnap];
            break;
            
        case NORMAL_COMPLETION_STATE:     // 4 Normal completion state
        default:
            self.cameraView.delegate = nil;
            [self.cameraView stop];
            [self.cameraView shutdown];
            
            terminationDelay = [self.captureParams[kMiSnapTerminationDelay] integerValue] / 1000.0;
            
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, terminationDelay * NSEC_PER_SEC);
            {
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                if (self.shouldDissmissOnSuccess)
                {
                    if (wself.navigationController == nil)
                    {
                        [wself dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        [wself.navigationController popViewControllerAnimated:YES];
                    }
                }
                if ([self.delegate respondsToSelector:@selector(miSnapDidFinishSuccessAnimation)])
                {
                    [self.delegate miSnapDidFinishSuccessAnimation];
                }
            });
            }
            break;
            
        case CANCEL_STATE:     // 5 Cancel state
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (wself.navigationController == nil)
                {
                    [wself dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [wself.navigationController popViewControllerAnimated:YES];
                }
            });
        }
            break;
            
    }
}

#pragma mark - Timer

- (void)stopTimer
{
    if (self.timer != nil)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startTimer:(NSTimeInterval)timeoutValue
{
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeoutValue/1000.0
                                                  target:self
                                                selector:@selector(timeoutOccurred:)
                                                userInfo:nil
                                                 repeats:1];
}

- (void)timeoutOccurred:(NSTimer *)timer
{
    self.shouldSkipFrames = YES;
    [self.cameraView turnTorchOff];
    
    NSDictionary *resultsDict = [self.captureView getDocumentResults];
    // These are the hints to show on failover view
    self.timeoutResults = [self.captureView getTimeoutResultsFromWarnings:[resultsDict objectForKey:kMiSnapResultWarnings]];
    if ([self.timeoutResults count] == 0) {
        NSInteger captureMode = [self.captureParams[kMiSnapCaptureMode] integerValue];
        if ((captureMode == MiSnapCaptureModeManual)
            || (captureMode == MiSnapCaptureModeManualAssist)
            || (captureMode == MiSnapCaptureModeHighResManual))
        {
            // Default messages for timeout manual
            self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:YES];
        }
        else{
            // Default messages for timeout auto
            self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:NO];
        }
    }
    self.timeoutDidOccur = TRUE;
    self.captureView.timeoutOccurred = TRUE;
    
    if (self.sessionIsInterrupted)
    {
        [self.sessionInterruptionView removeFromSuperview];
        self.sessionInterruptionView = nil;
        
        [self.sessionInterruptionLabel removeFromSuperview];
        self.sessionInterruptionLabel = nil;
        
        self.sessionIsInterrupted = NO;
        
        [self.captureView shutdown];
        [self runStateMachineAt:CANCEL_STATE];
    }
    else
    {
        [self.captureView shutdownForTimeout];
        [self runStateMachineAt:HELP_STATE];
    }
}

- (void)playShutterSound:(BOOL)vibrate
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSURL *soundFileURL = [bundle URLForResource:@"photoshutter" withExtension:@"wav"];
    
    SystemSoundID sound1;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &sound1) ;
    
    if (vibrate)
        AudioServicesPlayAlertSound(sound1);
    else
        AudioServicesPlaySystemSound(sound1);
}

- (void)playShutterSound
{
    [self playShutterSound:YES];
}

#pragma mark - MiSnapSDKCameraDelegate callbacks

- (void)didFinishConfiguringSession
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cameraView updatePreviewLayer:self.statusbarOrientation];
        [self.cameraView start];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"MiSnapShowTutorial"] == nil)
        {
            // If this is the first time we are running, set it to default YES (another dialog will change if the
            // user selected "don't show me again" button
            [defaults setBool:YES forKey:@"MiSnapShowTutorial"];
        }
        if ([defaults objectForKey:@"MiSnapShowTutorialDl"] == nil)
        {
            [defaults setBool:YES forKey:@"MiSnapShowTutorialDl"];
        }
        if ([defaults objectForKey:@"MiSnapShowTutorialPassport"] == nil)
        {
            [defaults setBool:YES forKey:@"MiSnapShowTutorialPassport"];
        }
        if ([defaults objectForKey:@"MiSnapShowTutorialIdFront"] == nil)
        {
            [defaults setBool:YES forKey:@"MiSnapShowTutorialIdFront"];
        }
        if ([defaults objectForKey:@"MiSnapShowTutorialIdBack"] == nil)
        {
            [defaults setBool:YES forKey:@"MiSnapShowTutorialIdBack"];
        }
        
        [defaults synchronize];
        
        if ([defaults boolForKey:@"MiSnapShowTutorialDl"] == YES && !self.firstTimeTutorialHasBeenShown && [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeDriverLicense])
        {
            [defaults setBool:NO forKey:@"MiSnapShowTutorialDl"];
            [defaults synchronize];
            
            self.firstTimeTutorialHasBeenShown = YES;
            
            [self.overlayView hideAllUIElements];
            [self runStateMachineAt:TUTORIAL_STATE];
        }
        else if ([defaults boolForKey:@"MiSnapShowTutorialPassport"] == YES && !self.firstTimeTutorialHasBeenShown && [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypePassport])
        {
            [defaults setBool:NO forKey:@"MiSnapShowTutorialPassport"];
            [defaults synchronize];
            
            self.firstTimeTutorialHasBeenShown = YES;
            
            [self.overlayView hideAllUIElements];
            [self runStateMachineAt:TUTORIAL_STATE];
        }
        else if ([defaults boolForKey:@"MiSnapShowTutorialIdFront"] == YES && !self.firstTimeTutorialHasBeenShown && [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardFront])
        {
            [defaults setBool:NO forKey:@"MiSnapShowTutorialIdFront"];
            [defaults synchronize];
            
            self.firstTimeTutorialHasBeenShown = YES;
            
            [self.overlayView hideAllUIElements];
            [self runStateMachineAt:TUTORIAL_STATE];
        }
        else if ([defaults boolForKey:@"MiSnapShowTutorialIdBack"] == YES && !self.firstTimeTutorialHasBeenShown && [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack])
        {
            [defaults setBool:NO forKey:@"MiSnapShowTutorialIdBack"];
            [defaults synchronize];
            
            self.firstTimeTutorialHasBeenShown = YES;
            
            [self.overlayView hideAllUIElements];
            [self runStateMachineAt:TUTORIAL_STATE];
        }
        else if ([defaults boolForKey:@"MiSnapShowTutorial"] == YES && !self.firstTimeTutorialHasBeenShown &&
                 (! [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeDriverLicense] &&
                  ! [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypePassport] &&
                  ! [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardFront] &&
                  ! [self.captureParams[kMiSnapDocumentType] isEqualToString:kMiSnapDocumentTypeIdCardBack]))
        {
            [defaults setBool:NO forKey:@"MiSnapShowTutorial"];
            [defaults synchronize];
            
            self.firstTimeTutorialHasBeenShown = YES;
            
            [self.overlayView hideAllUIElements];
            [self runStateMachineAt:TUTORIAL_STATE];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
            
            self.overlayView.hidden = YES;
            self.captureView.hidden = YES;
            
            MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.captureParams[@"LanguageOverride"]];
            
            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            self.sessionInterruptionView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            self.sessionInterruptionView.frame = self.view.bounds;
            
            self.sessionInterruptionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            self.sessionInterruptionLabel.font = [UIFont systemFontOfSize:35];
            self.sessionInterruptionLabel.numberOfLines = 4;
            self.sessionInterruptionLabel.textAlignment = NSTextAlignmentCenter;
            self.sessionInterruptionLabel.attributedText = [[NSAttributedString alloc] initWithString:[resourceLocator getLocalizedString:@"session_interruption_label"] attributes:@{
                                                                                                                                                                                      NSStrokeWidthAttributeName: [NSNumber numberWithInt:-2],
                                                                                                                                                                                      NSStrokeColorAttributeName: [UIColor whiteColor],
                                                                                                                                                                                      NSForegroundColorAttributeName: [UIColor blackColor]
                                                                                                                                                                                      }];
            
            [self checkIfSplitScreen];
            
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            self.overlayView.orientationMode = self.orientationMode;
            
            self.sessionInterruptionView.frame = self.view.bounds;
            self.sessionInterruptionLabel.frame = self.view.bounds;
            
            [self.overlayView manageTorchButton:self.cameraView.hasTorch];
            
            [self runStateMachineAt:CAPTURE_STATE];
        }
    });
}

- (void)didReceiveSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.shouldSkipFrames)
    {
        //NSLog(@"%%%%%% shouldSkipFrames %d", self.shouldSkipFrames);
        return;
    }
    [self.captureView didReceiveSampleBuffer:sampleBuffer];
}

- (void)didDecodeBarcode:(NSString *)decodedBarcodeString
{
    [self.captureView didDecodeBarcode:decodedBarcodeString];
}

#pragma mark - MiSnapCaptureViewDelegate callbacks

- (void)miSnapCaptureViewReceivingCameraOutput:(MiSnapSDKCaptureView *)captureView
{
    NSLog(@"MSVC miSnapCaptureViewReceivingCameraOutput");
    // Start the torch after the camera has started and camera output is being received
    [self.captureView startTorch];
}

- (void)miSnapCaptureViewCaptureStillImage
{
    [self.cameraView captureStillImageAsynchronouslyWithCompletionHandler:^(CMSampleBufferRef  _Nullable imageSampleBuffer, NSError * _Nullable error) {
        [self.captureView captureStill:imageSampleBuffer error:error];
    }];
}

- (void)miSnapCaptureViewTurnTorchOn
{
    [self.captureView turnTorchOn:[self.cameraView turnTorchOn]];
}

- (void)miSnapCaptureViewTurnTorchOff
{
    [self.captureView turnTorchOff:[self.cameraView turnTorchOff]];
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
             encodedImage:(NSString *)encodedImage
            originalImage:(UIImage *)originalImage
               andResults:(NSDictionary *)results
{
    // Timeout can occur just before successful capture. In this case, the timeout will invoke runStateMachineAt FAILOVER_CAPTURE_STATE
    // and we will ignore the startedAutoCapture and this callback.
    // Timeout has priority over capture because timeout starts the shutdown process and processing in the MiSnapCaptureView and the
    // run state machine become unpredictable.
    if (self.timeoutDidOccur == TRUE) {
        return;
    }
    [self stopTimer];
    
    self.imageCaptured = YES;
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([wself.delegate respondsToSelector:@selector(miSnapFinishedReturningEncodedImage:originalImage:andResults:forDocumentType:)])
        {
            [wself.delegate miSnapFinishedReturningEncodedImage:encodedImage originalImage:originalImage andResults:results forDocumentType:wself.captureParams[kMiSnapDocumentType]];
        }
        else if ([wself.delegate respondsToSelector:@selector(miSnapFinishedReturningEncodedImage:originalImage:andResults:)])
        {
            [wself.delegate miSnapFinishedReturningEncodedImage:encodedImage originalImage:originalImage andResults:results];
        }
        [wself runStateMachineAt:NORMAL_COMPLETION_STATE];
    });
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
            originalImage:(UIImage *)originalImage
               andResults:(NSDictionary *)results
{
    __weak MiSnapSDKViewController* wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        SEL selector = @selector(miSnapCapturedOriginalImage:andResults:);
        if ([wself.delegate respondsToSelector:selector])
        {
            [wself.delegate miSnapCapturedOriginalImage:originalImage andResults:results];
        }
    });
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
     cancelledWithResults:(NSDictionary *)results
{
    [self stopTimer];
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([wself.delegate respondsToSelector:@selector(miSnapCancelledWithResults:forDocumentType:)])
        {
            [wself.delegate miSnapCancelledWithResults:results forDocumentType:wself.captureParams[kMiSnapDocumentType]];
        }
        else if ([wself.delegate respondsToSelector:@selector(miSnapCancelledWithResults:)])
        {
            [wself.delegate miSnapCancelledWithResults:results];
        }
    });
}

- (void)miSnapCaptureViewStartedManualCapture:(MiSnapSDKCaptureView *)captureView
{
    [self stopTimer];
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.overlayView hideUIElementsOnSuccessfulCapture];
        
        [wself.overlayView hideSmartHint];
        [wself.overlayView hideHint];
        [wself.overlayView hideGhostImage];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [wself.overlayView runSnapAnimation];
    });
}

- (void)miSnapCaptureViewStartedAutoCapture:(MiSnapSDKCaptureView *)captureView withRect:(CGRect)documentRect
{
    // Timeout can occur just before successful capture. In this case, the timeout will invoke runStateMachineAt FAILOVER_CAPTURE_STATE
    // and we will ignore the startedAutoCapture.
    // Timeout has priority over capture because timeout starts the shutdown process and processing in the MiSnapCaptureView and the
    // run state machine become unpredictable.
    if (self.timeoutDidOccur == TRUE) {
        return;
    }
    
    [self stopTimer];
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.overlayView hideUIElementsOnSuccessfulCapture];
        
        [wself.overlayView hideSmartHint];
        [wself.overlayView hideHint];
        [wself.overlayView hideGhostImage];
        [wself.overlayView updateGaugeValue:100];
        [wself playShutterSound];
        [wself.overlayView runSnapAnimation];
        [wself.overlayView drawBoxAndBounce:documentRect];
    });
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView torchStatusDidChange:(BOOL)torchStatus
{
    self.torchWasON = torchStatus;
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.overlayView setTorchButtonStatus:torchStatus];
    });
}

- (CGRect)normalizeMinimumSizeOfGlareBox:(CGRect)boundingRect
{
    const float MIN_SIDE = 60.0f;
    const float HALF_MIN_SIDE = MIN_SIDE / 2;
    CGRect box = boundingRect;
    //NSLog(@"MSVC : self bounds %@", NSStringFromCGRect(self.view.bounds));
    //NSLog(@"MSVC : minBox IN  %@", NSStringFromCGRect(box));
    if (box.size.width < MIN_SIDE) {
        float adjustment = (HALF_MIN_SIDE - (box.size.width / 2));
        box = CGRectMake(box.origin.x - adjustment, box.origin.y, MIN_SIDE, box.size.height);
        //NSLog(@"MSVC : minBox W adjustment %0.2f boundingRect %@", adjustment, NSStringFromCGRect(box));
    }
    if (box.size.height < MIN_SIDE) {
        float adjustment = (HALF_MIN_SIDE - (box.size.height / 2));
        box = CGRectMake(box.origin.x, box.origin.y - adjustment, box.size.width, MIN_SIDE);
        //NSLog(@"MSVC : minBox H adjustment %0.2f boundingRect %@", adjustment, NSStringFromCGRect(box));
    }

    // Keep the box within the self.view.bounds
    if (box.origin.x < self.view.bounds.origin.x) {
        box = CGRectMake(self.view.bounds.origin.x, box.origin.y, box.size.width, box.size.height);
    }
    if (box.origin.y < self.view.bounds.origin.y) {
        box = CGRectMake(box.origin.x, self.view.bounds.origin.y, box.size.width, box.size.height);
    }
    if (box.origin.x + box.size.width > self.view.bounds.size.width) {
        box = CGRectMake(self.view.bounds.size.width - box.size.width, box.origin.y, box.size.width, box.size.height);
    }
    if (box.origin.y + box.size.height > self.view.bounds.size.height) {
        box = CGRectMake(box.origin.x, self.view.bounds.size.height - box.size.height, box.size.width, box.size.height);
    }
    //NSLog(@"MSVC : minBox OUT %@", NSStringFromCGRect(box));
    return box;
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString withBoundingRect:(CGRect)boundingRect {
    //NSLog(@"MSVC : userHintAvailable %@ boundingRect: x:%.0f y:%.0f w:%.0f h:%.0f", hintString, boundingRect.origin.x, boundingRect.origin.y, boundingRect.size.width, boundingRect.size.height);
    if (!self.showHintsInManualMode && [self isManualMode]) { return; }
    
    if ([hintString isEqualToString:kMiSnapHintGlare]) {
        __weak MiSnapSDKViewController* wself = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.overlayView showSmartHint:kMiSnapHintGlare withBoundingRect:[self normalizeMinimumSizeOfGlareBox:boundingRect]];
        });
    }
    else
    {
        NSString *message = @"Not defined";
        if ([hintString isEqualToString:kMiSnapHintGoodFrame])
        {
            message = kMiSnapHintGoodFrame;
        }
        else if ([hintString isEqualToString:kMiSnapHintLowContrast])
        {
            message = kMiSnapHintLowContrast;
        }
        else if ([hintString isEqualToString:kMiSnapHintBusyBackground])
        {
            message = kMiSnapHintBusyBackground;
        }
        else if ([hintString isEqualToString:kMiSnapHintNotCheckBack])
        {
            message = kMiSnapHintNotCheckBack;
        }
        else if ([hintString isEqualToString:kMiSnapHintNotCheckFront])
        {
            message = kMiSnapHintNotCheckFront;
        }
        else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
        {
            message = kMiSnapHintNothingDetected;
        }
        else if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            message = kMiSnapHintTooDim;
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            message = kMiSnapHintTooBright;
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            message = kMiSnapHintNotSharp;
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            message = kMiSnapHintRotation;
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            message = kMiSnapHintAngleTooLarge;
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            message = kMiSnapHintTooClose;
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            message = kMiSnapHintTooFar;
        }

        float width = 320;
        float height = 100;
        float originX = ([UIScreen mainScreen].bounds.size.width - width) / 2;
        float originY = ([UIScreen mainScreen].bounds.size.height - height) / 2;
        CGRect hintRect = CGRectMake(originX, originY, width, height);
        
        __weak MiSnapSDKViewController* wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.overlayView showSmartHint:message withBoundingRect:hintRect];
// Re-scales but causes flicker
//            [wself.overlayView scaleGhostImageWithOrientation:[UIApplication sharedApplication].statusBarOrientation];
        });
    }
}


#pragma mark - Event Handlers

- (void)cancelMiSnap
{
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.captureView cancel];
        self.cameraView.delegate = nil;
        [self.cameraView stop];
        [self.cameraView shutdown];
        
        if (wself.helpViewController != nil)
        {
            wself.overlayView.hidden = YES;
            [wself.captureView shutdown];
            
            if (wself.navigationController)
            {
                [wself.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [wself.helpViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            wself.helpViewController = nil;

            if (wself.navigationController == nil)
            {
                [wself dismissViewControllerAnimated:NO completion:nil];
            }
            else
            {
                [wself.navigationController popViewControllerAnimated:NO];
            }
        }
        else
        {
            [wself runStateMachineAt:CANCEL_STATE];
        }
    });
}

- (void)tutorialCancelButtonAction
{
    self.tutorialCancelled = YES;
    
    [self cancelMiSnap];
}

// Retry Auto capture mode
- (void)tutorialRetryButtonAction
{
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"centerContinueButtonClicked initialCaptureMode %@ captureParams %@", self.initialCaptureMode, self.captureParams);
        // Reset to auto capture mode
        [self.captureParams setValue:self.initialCaptureMode forKey:kMiSnapCaptureMode];
        if (wself.helpViewController != nil)
        {
            if (self.navigationController)
            {
                [wself.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [wself.helpViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            wself.helpViewController = nil;
        }
        else
        {
            [wself runStateMachineAt:CAPTURE_STATE];
        }
    });
}

- (void)tutorialContinueButtonAction
{
    if (self.helpViewController != nil)
    {
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self.helpViewController dismissViewControllerAnimated:YES completion:nil];
        }
        self.helpViewController = nil;
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self cancelMiSnap];
}

- (IBAction)torchButtonAction:(id)sender
{
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (wself.cameraView.isTorchOn)
        {
            self.torchWasON = FALSE;
            [wself.captureView turnTorchOff:[wself.cameraView turnTorchOff]];
            [wself.overlayView setTorchButtonStatus:FALSE];
        }
        else
        {
            self.torchWasON = TRUE;
            [wself.captureView turnTorchOn:[wself.cameraView turnTorchOn]];
            [wself.overlayView setTorchButtonStatus:TRUE];
        }
    });
}

- (IBAction)helpButtonAction:(id)sender
{
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.cameraView turnTorchOff];
        [wself.captureView shutdownForHelp];
        [wself showHelpView];
    });
}

- (IBAction)snapButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMiSnapCameraWasAdjusted object:nil];
    
    UIButton* button = (UIButton *)sender;
    button.hidden = YES;  // Prevent multiple clicks while processing the last click
    
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.overlayView hideUIElementsOnSuccessfulCapture];
        [wself.captureView captureCurrentFrame];
    });
}

- (void)showCaptureButton
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showManualCaptureButton) name:kMiSnapCameraWasAdjusted object:nil];
}

- (void)showManualCaptureButton
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMiSnapCameraWasAdjusted object:nil];
    
    __weak MiSnapSDKViewController *wself = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.overlayView showManualCaptureButton];
        });
    });
}

#pragma mark - Show Views

- (void)showMiSnap
{
    if ([self.delegate respondsToSelector:@selector(miSnapDidStartSession:)])
    {
        [self.delegate miSnapDidStartSession:self];
    }
    else
    {
        self.shouldSkipFrames = NO;
    }

    NSInteger captureMode = [self.captureParams[kMiSnapCaptureMode] integerValue];
    if ((captureMode == MiSnapCaptureModeManual)
        || (captureMode == MiSnapCaptureModeManualAssist)
        || (captureMode == MiSnapCaptureModeHighResManual))
    {
        [self showCaptureButton];
    }
    else if (captureMode == MiSnapCaptureModeDefault)
    {
        /////////////////////////////////////////////////////////////////////////////
        // Uncomment the showCaptureButton call below to display and enable
        // the manual button in default auto capture mode
        // [self showCaptureButton];
        /////////////////////////////////////////////////////////////////////////////
    }
    
    self.captureView.useBarcodeScannerLight = self.useBarcodeScannerLight;
    [self.captureView initializeObjectsWithCaptureParameters:self.captureParams];
    
    if ([self.captureParams[kMiSnapTorchMode] integerValue] == TorchModeAUTO)
    {
        self.cameraView.torchInAutoMode = YES;
        self.captureView.torchInAutoMode = YES;
    }
    else
    {
        self.cameraView.torchInAutoMode = NO;
        self.captureView.torchInAutoMode = NO;
    }
    
    // Management of overlayView and captureView is done in subclasses
    __weak MiSnapSDKViewController* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [wself.overlayView initializeObjects]; // Reset state on start or retry
        [wself.overlayView setupViewWithParams:wself.captureParams];
        
        wself.captureView.analyzeFrameDelay = self.analyzeFrameDelay;
        [wself.captureView start];
        wself.overlayView.alpha = 0.0;
        wself.overlayView.hidden = NO;
        [wself.overlayView manageTorchButton:wself.cameraView.hasTorch];
        
        wself.overlayView.showGlareTracking = self.showGlareTracking;
        wself.captureView.showGlareTracking = self.showGlareTracking;
        
        wself.captureView.alpha = 0.0;
        wself.captureView.hidden = NO;
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             wself.overlayView.alpha = 1.0;
                             wself.captureView.alpha = 1.0;
                             wself.cameraView.alpha = 1.0;
                         }
                         completion:nil];
    });
}

- (void)runSnapAnimation
{
    [self playShutterSound];
    [self.overlayView runSnapAnimation];
}

- (NSArray *)getTutorialMessagesForDocumentType:(NSString *)documentType isManualMode:(BOOL)isManualMode {
    NSString *message;
    if (([documentType isEqualToString:kMiSnapDocumentTypeACH])
        || ([documentType isEqualToString:kMiSnapDocumentTypeCheckFront]))
    {
        message = kMiSnapTutorialHelpCheckFront;
    }
    else if ([documentType isEqualToString:kMiSnapDocumentTypeCheckBack])
    {
        message = kMiSnapTutorialHelpCheckBack;
    }
    else if ([documentType hasPrefix:kMiSnapDocumentTypeDriverLicense])
    {
        message = kMiSnapTutorialHelpLicense;
    }
    else if ([documentType hasPrefix:kMiSnapDocumentTypePassport])
    {
        message = kMiSnapTutorialHelpPassport;
    }
    else
    {
        message = kMiSnapTutorialHelpDocument;
    }
    return [NSArray arrayWithObjects:message, isManualMode?kMiSnapTutorialPhotoManual:kMiSnapTutorialPhotoAuto, nil];
}

- (void)showTutorialView
{
    NSInteger captureMode = [self.captureParams[kMiSnapCaptureMode] integerValue];
    if ((captureMode == MiSnapCaptureModeManual)
        || (captureMode == MiSnapCaptureModeManualAssist)
        || (captureMode == MiSnapCaptureModeHighResManual))
    {
        // Default messages for timeout manual
        self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:YES];
    }
    else{
        // Default messages for timeout auto
        self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:NO];
    }
    
    [self showSmartTutorialWithNumberOfButtons:2 forDocumentType:self.captureParams[kMiSnapDocumentType] forTutorialMode:MiSnapTutorialModeFirstTime];
    return;
}

- (void)showSeamlessFailover
{
    self.shouldSkipFrames = YES;
    //NSLog(@"showSeemlessFailover %@", timeoutResults);
    
    __weak MiSnapSDKViewController* wself = self;
    int captureMode = (int)[self.captureParams[kMiSnapCaptureMode] integerValue];
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:wself.captureParams[@"LanguageOverride"]];
    
    NSString* msg = [resourceLocator getLocalizedString:@"help_seamless_failover"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *retryAuto = [UIAlertAction actionWithTitle:[resourceLocator getLocalizedString:@"dialog_mitek_try_again"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.shouldSkipFrames = NO;
                                    [wself runStateMachineAt:CAPTURE_STATE];
                                }];
    [alertController addAction:retryAuto];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:[resourceLocator getLocalizedString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                         {
                             if (captureMode == MiSnapCaptureModeHighRes)    // Special hi-res mode)
                             {
                                 [wself.captureParams setValue:@"6" forKey:kMiSnapCaptureMode];
                             }
                             else
                             {
                                 [wself.captureParams setValue:@"1" forKey:kMiSnapCaptureMode];
                             }
                             
                             [self.captureView initializeObjectsWithCaptureParameters:self.captureParams];
                             
                             self.shouldSkipFrames = NO;
                             [wself runStateMachineAt:FAILOVER_CAPTURE_STATE];
                         }];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showSmartTutorialWithNumberOfButtons:(int)numberOfButtons forDocumentType:(NSString *)documentType forTutorialMode:(MiSnapTutorialMode)tutorialMode
{
    __weak MiSnapSDKViewController* wself = self;
    
    self.shouldSkipFrames = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        wself.captureView.hidden = YES;
        wself.overlayView.hidden = YES;
        
        wself.helpViewController = nil;
        @try {
            // Customers who remove UX2 files will not have the UX2 storyboard and will get an exception
            wself.helpViewController = [[UIStoryboard storyboardWithName:@"MiSnapUX2" bundle:nil] instantiateViewControllerWithIdentifier:@"MiSnapSDKTutorialViewController"];
        } @catch (NSException *exception) {
            wself.helpViewController = [[UIStoryboard storyboardWithName:@"MiSnapUX1" bundle:nil] instantiateViewControllerWithIdentifier:@"MiSnapSDKTutorialViewController"];
        }
        wself.helpViewController.delegate = wself;

        NSInteger captureMode = [wself.captureParams[kMiSnapCaptureMode] integerValue];
        wself.helpViewController.isManualMode = (captureMode == MiSnapCaptureModeManual)
                                                || (captureMode == MiSnapCaptureModeManualAssist)
                                                || (captureMode == MiSnapCaptureModeHighResManual);
        wself.helpViewController.orientationMode = wself.orientationMode;
        wself.helpViewController.documentType = documentType;
        wself.helpViewController.tutorialMode = tutorialMode;
        
        // When no results, keep the default image for the failover view
        if ([self.timeoutResults count] > 0) {
            // Dots are tiled to match help and tutorial screens
            wself.helpViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-dots"]];
            wself.helpViewController.backgroundImageName = nil;
            
            MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:wself.captureParams[@"LanguageOverride"]];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;        // iPhone = 736, iPad = 1366
            CGFloat screenHeight = screenRect.size.height;      // iPhone = 414, iPad = 1024
            CGFloat fontSize = MAX(screenHeight, screenWidth) / 27.8f;
            NSInteger leftMargin = MAX(screenHeight, screenWidth) / 26.25f;
            NSInteger rightMargin = MAX(screenHeight, screenWidth) / 14.72f;
            NSInteger spacingHeight = MAX(screenHeight, screenWidth) / 40.0f;
            NSInteger pointerWidth = MAX(screenHeight, screenWidth) / 21.3f;
            NSInteger pointerHeight = pointerWidth / 2;
            NSDictionary *pointerMetrics = @{@"pointerWidth":[NSNumber numberWithInteger: pointerWidth], @"pointerHeight":[NSNumber numberWithInteger: pointerHeight]};
            NSDictionary *screenMetrics = @{@"leftMargin":[NSNumber numberWithInteger: leftMargin], @"rightMargin":[NSNumber numberWithInteger: rightMargin], @"spacingHeight":[NSNumber numberWithInteger: spacingHeight]};
            
            UIView *hintViewContainer = [UIView new];
            hintViewContainer.tag = 1111;
            UIView *hintView = [UIView new];
            [hintViewContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
            [hintView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [wself.helpViewController.view addSubview:hintViewContainer];
            [hintViewContainer addSubview:hintView];
            
            [wself.helpViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[hintViewContainer]-rightMargin-|" options:0 metrics:screenMetrics views:NSDictionaryOfVariableBindings(hintViewContainer)]];
            
            if (screenHeight / screenWidth > 1.78)
            {
                [wself.helpViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[hintViewContainer]-95-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hintViewContainer)]];
            }
            else if (screenWidth / screenHeight > 1.78)
            {
                [wself.helpViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[hintViewContainer]-75-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hintViewContainer)]];
            }
            else
            {
                [wself.helpViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[hintViewContainer]-60-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hintViewContainer)]];
            }
            
            [hintViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[hintView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hintViewContainer, hintView)]];
            
            NSLayoutConstraint *constraintVertical;
            constraintVertical = [NSLayoutConstraint constraintWithItem:hintView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:hintViewContainer
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0];
            [hintViewContainer addConstraint:constraintVertical];
            
            UILabel *lastHintLabel = nil;
            NSString *speakableText = @"";
            
            for (NSString *hint in self.timeoutResults) {
                
                UIImageView *hintPointerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"misnap_tutorial_red_arrow"]];
                UILabel *hintLabel = [UILabel new];
                
                NSString *localizedHint = [resourceLocator getLocalizedString:hint];
                speakableText = [speakableText stringByAppendingFormat:@"%@,,", localizedHint];
                
                [hintLabel setText:localizedHint];
                [hintLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
                [hintLabel setNumberOfLines:6];
                [hintLabel setTextColor:[UIColor blackColor]];
                
                
                [hintView addSubview:hintPointerView];
                [hintView addSubview:hintLabel];
                
                [hintPointerView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [hintLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
                NSDictionary *views = NSDictionaryOfVariableBindings(hintPointerView, hintLabel);
                
                [hintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[hintPointerView(pointerWidth)]-6-[hintLabel(>=200)]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:pointerMetrics views:views]];
                
                
                [hintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hintPointerView(pointerHeight)]" options:0 metrics:pointerMetrics views:views]];
                if (lastHintLabel == nil) {
                    [hintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[hintLabel(>=50)]" options:0 metrics:nil views:views]];
                }
                else {
                    NSDictionary *hintViews = NSDictionaryOfVariableBindings(hintLabel, lastHintLabel);
                    
                    [hintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastHintLabel]-spacingHeight-[hintLabel(>=50)]" options:0 metrics:screenMetrics views:hintViews]];
                }
                
                lastHintLabel = hintLabel;
                
            }
            
            [hintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastHintLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lastHintLabel)]];
            
            wself.helpViewController.speakableText = speakableText;
            
        }
        //NSLog(@"wself.helpViewController.speakableText %@", wself.helpViewController.speakableText);
        
        wself.helpViewController.languageOverride = self.captureParams[@"LanguageOverride"];
        wself.helpViewController.numberOfButtons = numberOfButtons;
        wself.helpViewController.timeoutDelay = 0;
        
        wself.helpViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        // For iOS 13, UIModalPresentationFullScreen is not the default, so be explicit
        wself.helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        if (wself.navigationController != nil)
        {
            [wself.navigationController pushViewController:wself.helpViewController animated:YES];
        }
        else
        {
            [wself presentViewController:self.helpViewController animated:YES completion:NULL];
        }
    });
}

- (void)showHelpView
{
    
    NSInteger captureMode = [self.captureParams[kMiSnapCaptureMode] integerValue];
    if ((captureMode == MiSnapCaptureModeManual)
        || (captureMode == MiSnapCaptureModeManualAssist)
        || (captureMode == MiSnapCaptureModeHighResManual))
    {
        // Default messages for timeout manual
        self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:YES];
    }
    else{
        // Default messages for timeout auto
        self.timeoutResults = [self getTutorialMessagesForDocumentType:self.captureParams[kMiSnapDocumentType] isManualMode:NO];
    }

    [self showSmartTutorialWithNumberOfButtons:2 forDocumentType:self.captureParams[kMiSnapDocumentType] forTutorialMode:MiSnapTutorialModeHelp];
    return;
}

#pragma mark - Public instance method implementations

- (void)setupMiSnapWithParams:(NSDictionary*)params
{
    MiSnapSDKParameters *misnapParams = [[MiSnapSDKParameters alloc] init];
    [misnapParams updateParameters:params];
    NSDictionary *parameters = [misnapParams toParametersDictionary];
    self.captureParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    self.captureParams[kMiSnapApplicationVersion] = self.applicationVersion;
    self.captureParams[kMiSnapShouldDismissOnSuccess] = [NSNumber numberWithBool:self.shouldDissmissOnSuccess];
    self.initialCaptureMode = self.captureParams[kMiSnapCaptureMode];
}

- (bool)checkCameraPermission
{
    return [MiSnapSDKCaptureView checkCameraPermission];
}

- (void)delayImageAnalysisFor:(float)seconds
{
    self.analyzeFrameDelay = seconds;
}

- (void)resumeAnalysis
{
    self.shouldSkipFrames = NO;
    //NSLog(@"$$$$$$ startCapture");
}

- (void)pauseAnalysis
{
    self.shouldSkipFrames = YES;
    //NSLog(@"$$$$$$ pauseCapture");
}

- (BOOL)isManualMode
{
    if ([self.captureParams[kMiSnapCaptureMode] integerValue] == MiSnapCaptureModeManual ||
        [self.captureParams[kMiSnapCaptureMode] integerValue] == MiSnapCaptureModeHighResManual ||
        [self.captureParams[kMiSnapCaptureMode] integerValue] == MiSnapCaptureModeManualAssist)
    {
        return TRUE;
    }
    
    return FALSE;
}

#pragma mark - Public class method implementations

+ (NSString*)miSnapVersion
{
    return [MiSnapSDKCaptureView miSnapVersion];
}

+ (NSString*)miSnapSDKScienceVersion
{
    return [MiSnapSDKCaptureView miSnapSDKScienceVersion];
}

+ (NSString*)mibiVersion
{
    return [MiSnapSDKCaptureView mibiVersion];
}

+ (NSDictionary*)defaultParameters
{
    return [MiSnapSDKParameters defaultParametersForACH];
}

+ (NSMutableDictionary*)defaultParametersForACH
{
    return [MiSnapSDKParameters defaultParametersForACH];
}

+ (NSMutableDictionary*)defaultParametersForCheckFront
{
    return [MiSnapSDKParameters defaultParametersForCheckFront];
}

+ (NSMutableDictionary*)defaultParametersForCheckBack
{
    return [MiSnapSDKParameters defaultParametersForCheckBack];
}

+ (NSMutableDictionary*)defaultParametersForRemittance
{
    return [MiSnapSDKParameters defaultParametersForRemittance];
}

+ (NSMutableDictionary*)defaultParametersForBalanceTransfer
{
    return [MiSnapSDKParameters defaultParametersForBalanceTransfer];
}

+ (NSMutableDictionary*)defaultParametersForW2
{
    return [MiSnapSDKParameters defaultParametersForW2];
}

+ (NSMutableDictionary*)defaultParametersForPassport
{
    return [MiSnapSDKParameters defaultParametersForPassport];
}

+ (NSMutableDictionary*)defaultParametersForDriversLicense
{
    return [MiSnapSDKParameters defaultParametersForDriversLicense];
}

+ (NSMutableDictionary*)defaultParametersForIdCardFront
{
    return [MiSnapSDKParameters defaultParametersForIdCardFront];
}

+ (NSMutableDictionary*)defaultParametersForIdCardBack
{
    return [MiSnapSDKParameters defaultParametersForIdCardBack];
}

+ (NSMutableDictionary*)defaultParametersForLandscapeDocument
{
    return [MiSnapSDKParameters defaultParametersForLandscapeDocument];
}

+ (NSMutableDictionary*)defaultParametersForBarcode
{
    return [MiSnapSDKParameters defaultParametersForBarcode];
}

+ (NSMutableDictionary*)defaultParametersForCreditCard
{
    return [MiSnapSDKParameters defaultParametersForCreditCard];
}

- (void)dealloc
{
    NSLog(@"MiSnapSDKViewController is deallocated");
}

@end
