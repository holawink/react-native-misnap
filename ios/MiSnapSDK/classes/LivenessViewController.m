//
//  LivenessViewController.m
//  SampleApp
//
//  Created by Jeremy Jessup on 4/7/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <MiSnapLiveness/MiSnapLiveness.h>
#import <AVFoundation/AVFoundation.h>
#import "LivenessViewController.h"
#import "LivenessTutorialViewController.h"
#import "LivenessHelpAutoViewController.h"
#import "LivenessHelpManualViewController.h"
#import "LivenessTimeoutViewController.h"
#import "NSString+Liveness.h"

/**
 * This class provides a user experience designed to guide the user toward a
 * successful automatic capture.  It uses a state-machine to track progress.
 *
 * State machine state paths:
 *
 * No_State 		-> Error 		| Tracking_Face
 * Tracking_Face 	-> Error 		| Liveness
 * Error    		-> No_State 	| Manual
 * Liveness			-> Error		| Success
 *
 */
typedef NS_ENUM(NSInteger, CaptureStateType)
{
	kCapture_No_State,			// no state
	kCapture_Error,				// any error state
	kCapture_Tracking_Face,		// face is actively being tracked
	kCapture_Liveness,			// tracked and liveness was detected (auto capture)
	kCapture_Success,			// successfully detected liveness and capture
	kCapture_Manual,			// user requested capture (manual mode)
};

@interface LivenessViewController () <MiSnapLivenessCaptureViewDelegate, LivenessTutorialViewControllerDelegate, LivenessTimeoutViewControllerDelegate, LivenessHelpAutoViewControllerDelegate, LivenessHelpManualViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MiSnapLivenessCaptureView *captureView;	// Liveness capture view
@property (weak, nonatomic) IBOutlet UIImageView *reticleImageView;             // The target oval
@property (weak, nonatomic) IBOutlet UIButton *manualButton;					// Manual capture button (hidden initially)
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;					// Cancel button
@property (weak, nonatomic) IBOutlet UIButton *helpButton;                      // Help button
@property (weak, nonatomic) IBOutlet UIView *hintView;                          // Container view for real-time hints
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;						// Hint text
@property (weak, nonatomic) IBOutlet UIImageView *successImageView;             // "Snap!" capture animation
@property (assign, nonatomic) CaptureStateType captureState;					// Current state
@property (strong, nonatomic) NSString *sessionGUID;							// Images are saved to flash - each with a random GUID name
@property (assign, nonatomic) BOOL timeoutTriggered;							// The SDK told us that timeout occurred, ignore capture events.
@property (assign, nonatomic) BOOL canSpeak;									// Because messages are real-time, we need to make sure accessibility is done before talking again
@property (strong, nonatomic) NSString *lastSpeakMessage;						// Cache previous hint message to not be overly repetitive
@property (assign, nonatomic) BOOL tutorialHasBeenShown;
@property (assign, nonatomic) BOOL tutorialCancelled;
@property (strong, nonatomic) NSTimer *messageTimer;
@end

@implementation LivenessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.captureView.backgroundColor = [UIColor blackColor];
    self.hintLabel.textColor = [UIColor blackColor];

	self.sessionGUID = [[NSUUID UUID] UUIDString];
	
	self.captureState = kCapture_No_State;
	self.navigationController.navigationBar.hidden = YES;
	self.successImageView.hidden = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.reticleImageView.image = [UIImage imageNamed:@"overlay-and-oval-ipad"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.captureView.licenseKey = self.licenseKey;
    
    // Present tutorial every time before a session started
    if (! self.tutorialHasBeenShown)
    {
        self.view.alpha = 0.0;
        self.view.hidden = YES;
        self.tutorialHasBeenShown = YES;
        LivenessTutorialViewController *tutorialVC = [LivenessTutorialViewController instantiateFromStoryboard];
        tutorialVC.delegate = self;
        tutorialVC.modalPresentationStyle = UIModalPresentationFullScreen;
        if (self.navigationController)
        {
            [self.navigationController presentViewController:tutorialVC animated:NO completion:nil];
        }
        else
        {
            [self presentViewController:tutorialVC animated:NO completion:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.tutorialCancelled)
    {
        [self dismissVCanimated:NO];
    }
    else
    {
        if (self.tutorialHasBeenShown)
        {
            [self startPreview];
        }
        [UIView animateWithDuration:1.0 animations:^{
            self.view.alpha = 1.0;
        }];
        self.view.hidden = NO;
    }
}

- (void)tutorialStartButtonPressed
{
    
}

- (void)tutorialCancelButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(livenessCancelled)])
    {
        [self.delegate livenessCancelled];
    }
    self.tutorialCancelled = YES;
    
    [self stopPreview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.sessionGUID = nil;
    self.lastSpeakMessage = nil;
	
	[self stopPreview];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)startPreview
{
    self.timeoutTriggered = FALSE;
    
    // Register for Accessibility notifications
    self.canSpeak = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishAnnouncement:) name: UIAccessibilityAnnouncementDidFinishNotification object:nil];
    
    if (self.captureParams == nil)
    {
        self.captureParams = [[MiSnapLivenessCaptureParameters alloc] init];
    }
	
	// Set the capture view delegate and capture parameters prior to calling 'start'
	self.captureView.delegate = self;
	self.captureView.captureParams = self.captureParams;
	[self.captureView start];
	
	// Toggle UI based on capture mode
	if (self.captureParams.captureMode == kLivenessCaptureMode_Manual)
	{
		self.manualButton.hidden = YES;
		self.manualButton.enabled = NO;
	}
}

- (void)stopPreview
{
	[self.captureView shutdown];
}

- (void)runSnapAnimation
{
	self.successImageView.hidden = YES;
    self.successImageView.image = [UIImage imageNamed:@"bug_animation_40"];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.successImageView.hidden = NO;
        self.successImageView.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.successImageView.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                self.successImageView.image = [UIImage imageNamed:@"success-check-icon"];
				self.hintView.backgroundColor = [UIColor clearColor];
                [self showPopup:@"CaptureSuccess" completionState:kCapture_Success];
        }];
    }];
}

- (void)didFinishAnnouncement:(NSNotification *)notif
{
	// Toggle that we can trigger another Accessibility hint, if needed
	self.canSpeak = TRUE;
}

#pragma mark - Button Handlers

- (IBAction)helpButtonPressed:(id)sender
{
    [self stopPreview];
	// Show appropriate help screen based on capture mode
	if (self.captureParams.captureMode == kLivenessCaptureMode_Automatic)
	{
        LivenessHelpAutoViewController *help = [LivenessHelpAutoViewController instantiateFromStoryboard];
        help.delegate = self;
        [self presentVC:help];
	}
	else
	{
        LivenessHelpManualViewController *help = [LivenessHelpManualViewController instantiateFromStoryboard];
        help.delegate = self;
		[self presentVC:help];
	}
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(livenessCancelled)])
    {
        [self.delegate livenessCancelled];
    }
    [self stopPreview];
	
    [self dismissVCanimated:YES];
}

- (IBAction)manualButtonPressed:(id)sender
{
	[self.captureView manualCaptureFrame];
	self.manualButton.enabled = NO;
	self.manualButton.hidden = YES;
}

#pragma mark - Control Logic

- (void)messageTimerExpired
{
    if (self.messageTimer)
    {
        [self.messageTimer invalidate];
        self.messageTimer = nil;
    }
}

// This method shows real-time hints and, if needed, plays an Accessibility message
- (void)showPopup:(NSString *)message completionState:(NSInteger)completionState
{
    if (self.messageTimer)
    {
        //NSLog(@"Return: message timer in progress");
        return;
    }
    else
    {
        //NSLog(@"Started message timer");
        self.messageTimer = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(messageTimerExpired) userInfo:nil repeats:NO];
    }
    
	self.captureState = completionState;
	self.hintView.hidden = NO;
    self.hintLabel.text = [NSString localizedStringForKey:message];
	
	// Post an accessibility message
	if (UIAccessibilityIsVoiceOverRunning() && self.canSpeak && [message caseInsensitiveCompare:self.lastSpeakMessage] != NSOrderedSame)
	{
		self.canSpeak = FALSE;
		self.lastSpeakMessage = message;
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString localizedStringForKey:message]);
	}
}

- (void)showErrorMessage:(MiSnapLivenessCaptureResults*)results
{
	//
	// Handle various error conditions from the MiSnapLiveness SDK
	//
    if (results.isErrorFaceNotCentered)
    {
        [self showPopup:@"Center face in the oval" completionState:kCapture_No_State];
    }
	else if (results.isErrorLowLighting)
	{
		[self showPopup:@"Low lighting" completionState:kCapture_No_State];
	}
	else if (!results.isFacePresent)
	{
		[self showPopup:@"No face detected" completionState:kCapture_No_State];
	}
	else if (results.isErrorTooFar)
	{
		[self showPopup:@"Get closer" completionState:kCapture_No_State];
	}
	else if (results.isErrorTooNear)
	{
		[self showPopup:@"Get farther" completionState:kCapture_No_State];
	}
	else if (results.isErrorDeviceTilt)
	{
		[self showPopup:@"Hold device upright" completionState:kCapture_No_State];
	}
    else if (results.shouldHoldStill)
    {
        [self showPopup:@"Hold still" completionState:kCapture_No_State];
    }
}

- (BOOL)doesResultsHaveErrors:(MiSnapLivenessCaptureResults*)results
{
	if (results.isErrorTooFar 		    ||
		results.isErrorTooNear		    ||
		results.isErrorLowLighting 	    ||
        results.isErrorFaceNotCentered  ||
		results.isErrorDeviceTilt 	    ||
		!results.isFacePresent          ||
        results.shouldHoldStill)
	{
		return TRUE;
	}
	
	return FALSE;
}

- (void)handleCaptureSuccess
{
	__block __weak LivenessViewController *wself = self;
	
	// Capture!  Play SFX.
	self.captureState = kCapture_Success;
	[self playShutterSoundAndVibrate:YES];
	
	// Hide the UI elements and get ready to transition
	dispatch_async(dispatch_get_main_queue(), ^{
		[wself runSnapAnimation];
		
		// hide UI elements
		wself.cancelButton.hidden 	= YES;
		wself.helpButton.hidden 	= YES;
		wself.manualButton.hidden 	= YES;
		wself.hintView.hidden 		= YES;
        wself.reticleImageView.hidden = YES;
        wself.captureView.backgroundColor = [UIColor whiteColor];
		[wself stopPreview];
	});
}

- (void)playShutterSoundAndVibrate:(BOOL)vibrate
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSURL *soundFileURL = [bundle URLForResource:@"liveness_photoshutter" withExtension:@"wav"];
    
    SystemSoundID sound1;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &sound1) ;
    
    if (vibrate)
    {
        AudioServicesPlayAlertSound(sound1);
    }
    else
    {
        AudioServicesPlaySystemSound(sound1);
    }
}

- (void)retryAuto:(BOOL)retry
{
    if (retry)
    {
        self.captureParams.captureMode = kLivenessCaptureMode_Automatic;
    }
    else
    {
        self.captureParams.captureMode = kLivenessCaptureMode_Manual;
    }
}

#pragma mark - MiSnapLivenessCaptureViewDelegate

// The user was unable to capture liveness in the timeout period
- (void)livenessTimeout
{
	// Set flag that we saw a timeout
	self.timeoutTriggered = TRUE;
	self.hintView.hidden = TRUE;
	
	[self stopPreview];
	
    LivenessTimeoutViewController *timeout = [LivenessTimeoutViewController instantiateFromStoryboard];
    timeout.delegate = self;
	[self presentVC:timeout];
}

// A successful capture occurred
- (void)livenessCaptureSuccess:(MiSnapLivenessCaptureResults*)results
{
	if (self.timeoutTriggered)
	{
		return;
	}
    
    if ([self.delegate respondsToSelector:@selector(livenessCaptureSuccess:)])
    {
        [self.delegate livenessCaptureSuccess:results];
    }
	
	// Change the full screen image to the framebuffer effectively stopping the real-time preview
	self.reticleImageView.image = results.capturedImage;
	
	// Uncomment this code to write the captured and Base-64 encoded image to the Documents directory
//    if (results.capturedImage != nil)
//    {
//        [MiSnapLivenessImageUtils writeImage:results.capturedImage withName:[NSString stringWithFormat:@"%@.jpg", self.sessionGUID]];
//
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *path = [paths[0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.b64", self.sessionGUID]];
//        [results.encodedImage writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
//    }

	// Update the UI
	[self handleCaptureSuccess];
    
	__block __weak LivenessViewController *wself = self;
	
	// Transition to the next view
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		dispatch_async(dispatch_get_main_queue(), ^{
            if (wself.navigationController)
            {
                [wself.navigationController popViewControllerAnimated:NO];
            }
            else
            {
                [wself dismissViewControllerAnimated:NO completion:nil];
            }
		});
	});
}

- (void)livenessResults:(MiSnapLivenessCaptureResults *)results
{
	//
	// State machine logic
	//
	
	// can't do any further analysis while an error message is displayed, or we've got a capture
	if (self.captureState == kCapture_Error || self.captureState == kCapture_Success)
	{
		return;
	}
	
	// no results
	if (results == nil)
	{
		return;
	}

	// from 'no state' - we can transition to frame errors or tracking the face
	if (self.captureState == kCapture_No_State)
	{
		// if there are errors
		if ([self doesResultsHaveErrors:results])
		{
			[self showErrorMessage:results];
		}
		// no errors?  is a face present?
		else if ([results isFacePresent])
		{
			// start tracking the face
			self.captureState = kCapture_Tracking_Face;
		}
	}
	// from 'tracking' - we can transition to errors or a capture
	else if (self.captureState == kCapture_Tracking_Face)
	{
		if ([self doesResultsHaveErrors:results])
		{
			// showing an error message switches state to error or none
			[self showErrorMessage:results];
		}
		else
		{
			if (self.captureView.captureParams.captureMode == kLivenessCaptureMode_Automatic)
			{
				[self showPopup:@"Blink!" completionState:kCapture_Liveness];
			}
			else
			{
				[self showPopup:@"Tap Now!" completionState:kCapture_Liveness];
                self.manualButton.hidden = NO;
                self.manualButton.enabled = YES;
			}
		}
	}
	// from 'liveness' - we can transition to 'errors' or a capture
	else if (self.captureState == kCapture_Liveness)
	{
		if ([self doesResultsHaveErrors:results])
		{
			// showing an error message switches state to error or none
			[self showErrorMessage:results];
		}
	}
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass([self class]);
}

+ (LivenessViewController *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"FacialCaptureUX" bundle:nil] instantiateViewControllerWithIdentifier:[LivenessViewController storyboardIdentifier]];
}

- (void)presentVC:(UIViewController *)vc
{
    if (self.navigationController)
    {
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)dismissVCanimated:(BOOL)animated
{
    if (self.navigationController)
    {
        [self.navigationController popToRootViewControllerAnimated:animated];
    }
    else
    {
        [self dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)dealloc
{
    //NSLog(@"LivenessViewController is being deallocated");
}

@end
