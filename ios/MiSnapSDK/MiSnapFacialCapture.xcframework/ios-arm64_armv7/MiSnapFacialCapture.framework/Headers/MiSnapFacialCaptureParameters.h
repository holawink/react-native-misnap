//
//  MiSnapFacialCaptureParameters.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureCameraParameters.h>

/**
 *  Defines the modes supported by MiSnapFacialCapture.
 *  The default and recommended mode is Auto (`MiSnapFacialCaptureModeAuto`).
 *
 *  - Since: 3.0.0
 */
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureMode)
{
    MiSnapFacialCaptureModeNone     = 0,
    MiSnapFacialCaptureModeManual   = 1,
    MiSnapFacialCaptureModeAuto     = 2
};

/**
 *  Defines the tutorial modes supported by MiSnapFacialCapture.
 *
 *  - Since: 3.0.0
 */
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureTuturialMode)
{
    MiSnapFacialCaptureTuturialModeNone = 0,
    MiSnapFacialCaptureTuturialModeInstruction,
    MiSnapFacialCaptureTuturialModeHelp,
    MiSnapFacialCaptureTuturialModeTimeout,
    MiSnapFacialCaptureTuturialModeReview
};

/**
MiSnapFacialCaptureParameters is a class that defines an interface for controlling a frame selection thresholds.
*/
@interface MiSnapFacialCaptureParameters : NSObject

/**
 Creates and returns parameters object with default parameter values.
 @return An instance of `MiSnapFacialCaptureParameters`
 - Since: 3.0.0
*/
- (instancetype _Nonnull)init;

/**
 The mode that the MiSnapFacialCaptureAnalyzer should use.
 @see `MiSnapFacialCaptureMode` for details on the modes.
 Default: `MiSnapFacialCaptureModeAuto`
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) MiSnapFacialCaptureMode mode;

/**
 The amount of time (seconds) to wait for a successful image selection in Auto mode
 
 Range: [3..30]
 
 Default: 20
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger timeout;

/**
 Minimum percentage a face should fill a view width-wise to select an image
 
 Range: [400..800]
 
 Default: 550
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger minFill;

/**
 Maximum percentage a face should fill a view width-wise to select an image
 
 Range: [400..800]
 
 Default: 725
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger maxFill;

/**
 Roll threshold (head leans left and right)
 
 Range: [0..1000]
 
 Default: 500
 
 Note: the greater the value the more stringent SDK is. It's recommended to use a default value
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger roll;

/**
 Pitch threshold (nose moves up and down / nod)
 
 Range: [0..1000]
 
 Default: 500
 
 Note: the greater the value the more stringent SDK is. It's recommended to use a default value
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger pitch;

/**
 Yaw threshold (nose moves left to right and vice versa)

 Range: [0..1000]
 
 Default: 500
 
 Note: the greater the value the more stringent SDK is. It's recommended to use a default value
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger yaw;

/**
 Image quality compression to apply
 
 Range: [5..100]
 
 Default: 95
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger imageQuality;

/**
 Indicates whether an image selection should be triggered by a smile
 
 Default: `FALSE`
 
 When set to `FALSE` the first frame that meets environmental thresholds defined by this class is selected
 When set to `TRUE` a frame is captured on a smile trigger
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) BOOL selectOnSmile;

/**
 Time in seconds before an image should be selected
 
 Range: [0..5]
 
 Default: 2
 
 Note: `selectOnSmile` parameter has to be overridden to `FALSE` for this parameter to become active
 
 When greater than or equal to `2` `MiSnapFacialCaptureAnalyzerDelegate` protocol will
 send `startCountdown` callback when the first frame that satisies all threesholds is detected
 
 When set to less than `2` then the first frame that satisfies all thresholds will be selected without
 sending `startCountdown` callback
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) NSInteger countdownTime;

/**
 Indicates whether an overlay should display detected face landmarks for debugging purposes
 
 Default: `FALSE`
 
 - Since: 3.0.0
 */
@property (nonatomic, readwrite) BOOL highlightLandmarks;

/**
 An object that configures camera specific parameters
 - Since 3.1.0
 */
@property (readwrite, nonatomic) MiSnapFacialCaptureCameraParameters * _Nonnull cameraParameters;

@end
