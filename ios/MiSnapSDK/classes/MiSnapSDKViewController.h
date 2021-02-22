//
//  MiSnapSDKViewController.h
//  MiSnapDevApp
//
//  Created by Steve Blake on 11/21/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UiKit/UIKit.h>
#import <MiSnapSDK/MiSnapSDK.h>

#define TUTORIAL_STATE              0
#define CAPTURE_STATE               1
#define HELP_STATE                  2
#define FAILOVER_CAPTURE_STATE      3
#define NORMAL_COMPLETION_STATE     4
#define CANCEL_STATE                5

@class MiSnapSDKViewController;

/*!
 
 Apps making use of the MiSnap SDK must conform to this protocol in order to be called by
 MiSnap for successuful capture with image data or cancelled session, both with results.
 
 */
@protocol MiSnapViewControllerDelegate <NSObject>
@optional

/*! @abstract This delegate callback method is called upon successful image capture or decode.
 @param encodedImage for resultCode @link kMiSnapResultSuccessVideo @/link or
 @link kMiSnapResultSuccessStillCamera @/link, this will be a scaled,
 compressed and base64 encoded image, with BI/UXP data embedded as an
 Exif comment in the encoded JPEG, suitable for processing on a Mitek
 Systems mobile imaging server; for resultCode
 @link kMiSnapResultSuccessPDF417 @/link, this value will be nil.
 @param originalImage for resultCode @link kMiSnapResultSuccessVideo @/link or
 @link kMiSnapResultSuccessStillCamera @/link, this will be the original
 unmodified image; for resultCode kMiSnapResultSuccessPDF417, this value
 will be nil.
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link).
 For resultCode @link kMiSnapResultSuccessPDF417 @/link, this dictionary
 will also contain the decoded PDF417 data (via key
 @link kMiSnapPDF417Data @/link). For image-based result codes, the value
 obtained via key @link kMiSnapMIBIData @/link will contain recorded
 environmental factors at the time the image was captured (focus quality,
 brightness level, etc.) plus user experience data during the
 auto-capture process.
 */
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage
                              originalImage:(UIImage *)originalImage
                                 andResults:(NSDictionary *)results;

/*! @abstract This delegate callback method is called upon successful image capture or decode.
 @param encodedImage for resultCode @link kMiSnapResultSuccessVideo @/link or
 @link kMiSnapResultSuccessStillCamera @/link, this will be a scaled,
 compressed and base64 encoded image, with BI/UXP data embedded as an
 Exif comment in the encoded JPEG, suitable for processing on a Mitek
 Systems mobile imaging server; for resultCode
 @link kMiSnapResultSuccessPDF417 @/link, this value will be nil.
 @param originalImage for resultCode @link kMiSnapResultSuccessVideo @/link or
 @link kMiSnapResultSuccessStillCamera @/link, this will be the original
 unmodified image; for resultCode kMiSnapResultSuccessPDF417, this value
 will be nil.
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link).
 For resultCode @link kMiSnapResultSuccessPDF417 @/link, this dictionary
 will also contain the decoded PDF417 data (via key
 @link kMiSnapPDF417Data @/link). For image-based result codes, the value
 obtained via key @link kMiSnapMIBIData @/link will contain recorded
 environmental factors at the time the image was captured (focus quality,
 brightness level, etc.) plus user experience data during the
 auto-capture process.
 @param docType a document type used for capturing a document. See <MiSnapSDK/MiSnapSDK.h> for
 a full list of available document types
 */
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage
                              originalImage:(UIImage *)originalImage
                                 andResults:(NSDictionary *)results
                            forDocumentType:(NSString *)docType;

/*!
 
 @abstract invoked if the user cancels a capture MiSnap transaction or other conditions occur
 that cause a MiSnap transaction to end without capturing an image.
 
 @discussion The result code will be @link kMiSnapResultCancelled @/link if the user touched the X Cancel
 button during capture.
 
 The result code will be @link kMiSnapResultCameraNotSufficient @/link if the device does not
 support capturing a 2 Megapixel image.
 
 The results will also contain a value for the key @link kMiSnapMIBIData @/link if such data
 was captured prior to cancellation or other termination conditions.
 
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link)
 and other information about the termination of the MiSnap transaction.
 
 */
- (void)miSnapCancelledWithResults:(NSDictionary *)results;

/*!
 
 @abstract invoked if the user cancels a capture MiSnap transaction or other conditions occur
 that cause a MiSnap transaction to end without capturing an image.
 
 @discussion The result code will be @link kMiSnapResultCancelled @/link if the user touched the X Cancel
 button during capture.
 
 The result code will be @link kMiSnapResultCameraNotSufficient @/link if the device does not
 support capturing a 2 Megapixel image.
 
 The results will also contain a value for the key @link kMiSnapMIBIData @/link if such data
 was captured prior to cancellation or other termination conditions.
 
 @param results dictionary containing the result code (via key @link kMiSnapResultCode @/link)
 and other information about the termination of the MiSnap transaction.
 
 @param docType a document type used for capturing a document. See <MiSnapSDK/MiSnapSDK.h> for
 a full list of available document types
 
 */
- (void)miSnapCancelledWithResults:(NSDictionary *)results forDocumentType:(NSString *)docType;

/*! Not implemented in MiSnapSDK. This may be useful in a test scenario.
 This event allows the app developer to send captured images or other images in an alternate callback.
 */
- (void)miSnapCapturedOriginalImage:(UIImage *)originalImage
                         andResults:(NSDictionary *)results;

/*!
 @abstract invoked whenever MiSnap starts a capture session. Also invoked when the session is restarted after timeout or failover.
 
 @discussion The start of a session may be important to client apps to modify or customize the session.  Using this
 method allows the client to show some additional information to the user, or invoke a delay of the image analysis,
 or any other desired action.
 
 This is invoked for all document types and capture modes.
 
 @param controller that started MiSnap.
 
 */
- (void)miSnapDidStartSession:(MiSnapSDKViewController *)controller;

/*!
@abstract invoked when success animation is completed

@discussion The event when MiSnap is completed success animation may be important to client apps to modify or customize the session.
It is useful when shouldDissmissOnSuccess is overridden to FALSE
*/
- (void)miSnapDidFinishSuccessAnimation;

@end


@interface MiSnapSDKViewController : UIViewController

/*! @abstract a pointer back to the method implementing the callback methods MiSnap will invoke
 upon transaction termination
 */
@property (weak, nonatomic) NSObject<MiSnapViewControllerDelegate>* delegate;

/*! @abstract Orientations supported by MiSnap.
 
 Default for ID doc types Driver License, ID Card Front and Back = MiSnapOrientationModeDevicePortraitGhostLandscape
 Default for ID doc type Passport = MiSnapOrientationModeDeviceLandscapeGhostLandscape
 Default for other doc types = MiSnapOrientationModeDeviceLandscapeGhostLandscape
 
 @see MiSnapOrientationMode enum for all supported orientation modes
 */
@property (nonatomic, assign) MiSnapOrientationMode orientationMode;

/*!
 @abstract Used to set the application version that will appear in the MiBi dataset
 Version is truncated to a maximum length of 20 characters
 */
@property (nonatomic) NSString *applicationVersion;

/*! @abstract When TRUE, During an auto capture session, MiSnap displays a customizable border highlighting the location of glare on a document surface.
 
 @note The rectangular smart box border is customizable by setting the variables glareBoxBackgroundColor, glareBoxBorderColor, glareBoxBorderWidth, and glareBoxCornerRadius.  The variables are declared in UX1_Files/MiSnapOverlayViewUX1.m and UX2_Files/MiSnapOverlayViewUX2.m.
 default = TRUE
 */
@property (nonatomic, assign) BOOL showGlareTracking;

/*! @abstract When TRUE, On successful completion of an auto capture session, the MiSnapSDKViewController dismisses itself.
 When FALSE, the MiSnapSDKViewController does not dismisses itself and it is the responsibility of it's parent view controller to
 dismiss the MiSnapSDKViewController.
 
 @note The dismissal occurs after the termination delay defined by the kMiSnapTerminationDelay parameter.
 default = TRUE
 */
@property (nonatomic, assign) BOOL shouldDissmissOnSuccess;

/*! @abstract When TRUE, hints are displayed in Manual mode.
 When FALSE, hints are not displayed in Manual mode
 default = FALSE
 */
@property (nonatomic, assign) BOOL showHintsInManualMode;

/*! @abstract Checks whether the app has been given permission to use the camera.  Returns TRUE if it has,
 return FALSE permission was denied or pending.  If false, the app should not call MiSnap until subsequent
 calls return TRUE.  Only checks if the current iOS version greater than or equal to 8.0, return TRUE if less than 8.0
 */
- (bool)checkCameraPermission;

/*! @abstract When TRUE, MiSnapBarcodeScannerLight is used for detecting a barcode when kMiSnapDocumentTypeIdCardBack is invoked.
 When FALSE, MiSnapBarcodeScanner is used for detecting a barcode when kMiSnapDocumentTypeIdCardBack is invoked.
 
 @note Applicable only when kMiSnapDocumentTypeIdCardBack is used for capturing a document.
 When FALSE and MiSnapBarcodeScanner is not integrated a FrameworkNotFoundException is raised resulting in a crash.
 default = TRUE
 */
@property (nonatomic, assign) BOOL useBarcodeScannerLight;

/*!
 The setupMiSnapWithParams method accepts parameters from the calling app.
 
 The dictionary of parameters sent to this method will replace any parameters previously
 established via this call.
 
 If this method is not called, a set of defaults will be internally established.
 
 @abstract method to establish parameters MiSnap will use during operation
 @param params key-value pairs whose range of eligible keys are drawn from NSString* values
 in @link //apple_ref/doc/header/MiSnapSDK.h @/link
 in group MiSnap Input Parameters keys
 
 */
- (void) setupMiSnapWithParams:(NSDictionary *)params;

/*! @abstract set a delay in image analysis from the time the first successful image is found.
 After the delay, frame analysis resumes and the next successful image can be captured.
 @param seconds to delay.
 */
- (void)delayImageAnalysisFor:(float)seconds;

/*! @abstract pause analysis of images. The camera will continue to run but images are not analyzed or captured.*/
- (void)pauseAnalysis;

/*! @abstract resume analysis of images. A successful image can be captured. */
- (void)resumeAnalysis;

/*! @abstract the current MiSnap SDK version
 @return string representing the current MiSnap SDK version
 */
+ (NSString *)miSnapVersion;

/*! @abstract the current MiSnap SDK Science version
 @return string representing the current MiSnap SDK Science version
 */
+ (NSString*)miSnapSDKScienceVersion;

/*!
 @abstract Used to identify the current set of returned MiBI values
 @return a string the represents the MiBI dataset version
 */
+ (NSString *)mibiVersion;

/*! Returns default parameters suitable for capturing an ACH Enrollment check. */
+ (NSMutableDictionary*)defaultParametersForACH;

/*! Returns default parameters suitable for capturing a Check Front. */
+ (NSMutableDictionary*)defaultParametersForCheckFront;

/*! Returns default parameters suitable for capturing a Check Back. */
+ (NSMutableDictionary*)defaultParametersForCheckBack;

/*! Returns default parameters suitable for capturing a Bill Pay / Remittance document. */
+ (NSMutableDictionary*)defaultParametersForRemittance;

/*! Returns default parameters suitable for capturing a Balance Transfer. */
+ (NSMutableDictionary*)defaultParametersForBalanceTransfer;

/*! Returns default parameters suitable for capturing a W2. */
+ (NSMutableDictionary*)defaultParametersForW2;

/*! Returns default parameters suitable for capturing a Passport. */
+ (NSMutableDictionary*)defaultParametersForPassport;

/*! Returns default parameters suitable for capturing a Driver's License. */
+ (NSMutableDictionary*)defaultParametersForDriversLicense;

/*! Returns default parameters suitable for capturing a front of ID Card. */
+ (NSMutableDictionary*)defaultParametersForIdCardFront;

/*! Returns default parameters suitable for capturing a back of ID Card. */
+ (NSMutableDictionary*)defaultParametersForIdCardBack;

/*! Returns default parameters suitable for capturing a high resolution landscape document. */
+ (NSMutableDictionary*)defaultParametersForLandscapeDocument;

/*! Returns default parameters suitable for capturing a barcode. */
+ (NSMutableDictionary*)defaultParametersForBarcode;

/*! Returns default parameters suitable for capturing a Credit Card. */
+ (NSMutableDictionary*)defaultParametersForCreditCard;

@end

#import "MiSnapSDKViewController.h"

@interface MiSnapSDKViewController (MiSnapPrivate)


#pragma mark - Candidates for API

/*! this convenience routines allows the caller to create a @link MiSnapSDKViewController @/link
 and initialize the parameters in a single call.
 
 @abstract convenience initializer which calls @link setupMiSnapParams: @/link as part of init
 @param parametersDictionary a dictionary containing objects designated by keys drawnfrom
 @link //apple_ref/doc/header/MiSnap.h @/link
 in group MiSnap Input Parameters key constants
 @return an initialized MiSnapSDKViewController, with the parameters established
 
 */
- (id)initWithParameters:(NSDictionary*)parametersDictionary;

#pragma mark - Allow visibility for TestDeckViewController

// Allow visibility for TestDeckViewController
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString;
// Allow visibility for TestDeckViewController
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString withBoundingRect:(CGRect)boundingRect;
// Allow visibility for TestDeckViewController
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView completionScoreUpdated:(int)completionScore withDocumentRect:(CGRect)documentRect;
// Allow visibility for TestDeckViewController
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
             encodedImage:(NSString *)encodedImage
            originalImage:(UIImage *)originalImage
               andResults:(NSDictionary *)results;
// Allow visibility for TestDeckViewController
- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView
     cancelledWithResults:(NSDictionary *)results;

@end

