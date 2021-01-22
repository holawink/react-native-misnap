//
//  MiSnapSDKTutorialViewController.h
//  MiSnap
//
//  Created by Greg Fisch on 7/30/14.
//  Copyright (c) 2014 mitek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapSDK/MiSnapSDK.h>

@protocol MiSnapTutorialViewControllerDelegate <NSObject>

- (void)tutorialCancelButtonAction;
- (void)tutorialContinueButtonAction;
- (void)tutorialRetryButtonAction;

@end

@interface MiSnapSDKTutorialViewController : UIViewController

/*! @abstract a pointer back to the method implementing the callback methods MiSnapTutorial will invoke
 upon transaction termination
 */
@property (weak, nonatomic) NSObject<MiSnapTutorialViewControllerDelegate>* delegate;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *buttonBackgroundView;

@property (nonatomic) NSString* backgroundImageName;
@property (nonatomic) NSString* speakableText;
@property (nonatomic) NSString* languageOverride;
@property (nonatomic) NSString* documentType;
@property (nonatomic, assign) MiSnapTutorialMode tutorialMode;

@property (nonatomic, assign) int numberOfButtons;
@property (nonatomic, assign) NSTimeInterval timeoutDelay;

@property (nonatomic, assign) BOOL isManualMode;
@property (nonatomic, assign) MiSnapOrientationMode orientationMode;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)retryButtonAction:(id)sender;
- (IBAction)continueButtonAction:(id)sender;

@end
