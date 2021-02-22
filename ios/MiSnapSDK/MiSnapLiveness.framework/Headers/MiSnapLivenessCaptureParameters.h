//
//  MiSnapLivenessCaptureParameters.h
//  MiSnapLiveness
//
//  Created by Jeremy Jessup on 3/30/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Defines the capture modes supported by MiSnap Liveness.
 *  The default and recommended capture mode is automatic (`kLivenessCaptureMode_Automatic`).
 *
 *  - Since: 1.0
 */
typedef NS_ENUM(NSInteger, MiSnapLivenessCaptureMode) {
	/**
	 *  Manual capture mode.
	 *  To capture a frame, the host must call `[MiSnapLivenessCaptureView manualCaptureFrame]`
	 *  to receive a result.
	 *
	 *  - Since: 1.0
	 */
	kLivenessCaptureMode_Manual = 1,

	/**
	 *  Automatic capture mode.  
	 *  When the frame analysis meets or exceeds the thresholds set by various 
	 *  MiSnapLivenessCaptureParameters, a frame is captured and returned to the delegate.
	 *
	 *  - Since: 1.0
	 */
	kLivenessCaptureMode_Automatic = 2,
	
};

/**
 *  The MiSnap Liveness Capture Parameters define minimum thresholds
 *  an analyzed video frame must meet for a capture to occur.
 *
 *  The parameters are clamped to a valid range when set.
 *
 *  Combined with `MiSnapLivenessCaptureResults`, user-experience events can
 *  be derived to help the user capture an optimal image.
 *
 *  Example: If the device tiltAngle exceeds the threshold, the `MiSnapLivenessResultType.kLiveness_Error_Device_Tilt`
 *  flag will be set.
 *
 *  @note This class conforms to the `NSCoding` protocol and supports serialization.
 *  @see `MiSnapLivenessCaptureResults`
 *  - Since: 1.0
 */
@interface MiSnapLivenessCaptureParameters : NSObject <NSCoding>

/**
 *  The capture mode that the MiSnapLivenessCaptureView should use.
 *
 *  @see `MiSnapLivenessCaptureMode` for details on the modes.
 *
 *  - since: 1.0
 */
@property (nonatomic, assign) MiSnapLivenessCaptureMode captureMode;

/**
 *  The minimum score of an overall liveness check when a subject blinks.
 *
 *  Range: [0..1000] - Default: 500
 *
 *  - Since: 1.0
 */
@property (nonatomic, assign) int livenessScore;

/**
 *  The minimum score to detect a blink.  A higher value is more
 *  restrictive.
 *
 *  Range: [0..1000] - Default: 400
 *  - Since: 1.0
 */
@property (nonatomic, assign) int blinkScore;

/**
 *  The maximum allowable device tilt in degrees to allow capture.
 *  The device can be angled up to (90 degrees - `tiltAngle`) without tilt.
 *
 *  Range: [0..90] - Default: 25
 *  - Since: 1.0
 */
@property (nonatomic, assign) int tiltAngle;

/**
 *  The distance between eyes in pixels.
 *  Values below the minimum set `MiSnapLivenessResultType.kLiveness_Error_Too_Near` flag.
 *
 *  Range: [0..256] - Default: 90
 *
 *  @see `MiSnapLivenessCaptureResults` and `MiSnapLivenessCaptureView`
 *  - Since: 1.0
 */
@property (nonatomic, assign) int eyeMinDistance;

/**
 *  The distance between eyes in pixels.
 *  Values above the threshold set `MiSnapLivenessResultType.kLiveness_Error_Too_Far` flag.
 *
 *  Range: [0..256] - Default: 160
 *
 *  @see `MiSnapLivenessCaptureResults` and `MiSnapLivenessCaptureView`
 *  - Since: 1.0
 */
@property (nonatomic, assign) int eyeMaxDistance;

/**
 *  The lighting threshold.
 *  Values below the minimum set `MiSnapLivenessResultType.kLiveness_Error_Low_Lighting` flag.
 * 
 *  Range: [0..1000] - Default: 350
 *
 *  @see `MiSnapLivenessCaptureResults` and `MiSnapLivenessCaptureView`
 *  - Since: 1.0
 */
@property (nonatomic, assign) int lighting;

/**
 *  The image sharpness.
 *  Values below the minimum set `MiSnapLivenessResultType.kLiveness_Error_Low_Sharpness` flag.
 *
 *  Range: [0..1000] - Default: 200
 *
 *  @see `MiSnapLivenessCaptureResults` and `MiSnapLivenessCaptureView`
 *  - Since: 1.0
 */
@property (nonatomic, assign) int sharpness;

/**
 *  If `TRUE`, the capture view will allocate additional memory to cache
 *  a video frame prior to the liveness detection event.  This frame may
 *  contain an image of the subject with eyes open.
 *
 *  Default: `TRUE`
 *
 *  - Since: 1.0
 */
@property (nonatomic, assign) BOOL captureEyesOpen;

/**
 *  The amount of time (seconds) to wait for a successful capture.
 *  When the timeout limit is reached, the delegate is notified.
 *
 *  Range: [10..60] - Default: 20
 *
 *  @see `MiSnapLivenessCaptureView`
 *  - Since: 1.0
 */
@property (nonatomic, assign) int timeout;

/**
 *  Image quality compression to apply
 *
 *  Range: [0..100] - Default: 100
 *
 *  @see `MiSnapLivenessCaptureView`
 *  - Since: 2.0.2
 */
@property (nonatomic, assign) int imageQuality;

/**
 *  Creates and returns a capture parameters object with default parameter values.
 *
 *  @return An instance of `MiSnapLivenessCaptureParameters`
 *
 *  - Since: 1.0
 */
- (instancetype)init;

/**
 *  Resets the instance properties to default values.
 *
 *  - Since: 1.0
 */
- (void)resetToDefaults;

@end
