//
//  MiSnapLivenessCaptureResults.h
//  MiSnapLiveness
//
//  Created by Jeremy Jessup on 4/4/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  `MiSnapLivenessResultType` defines various analysis conditions of a video frame.
 *  This is implemented as a bit-field as multiple properties can occur simultaneously per frame.
 *
 *  - Since: 1.0
 */
typedef NS_OPTIONS(NSInteger, MiSnapLivenessResultType) {
	/**
	 *  A face is being tracked.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Is_Tracking_Face			= 1 << 0,
	
	/**
	 *  Liveness Success - the subject is alive (blinked).
	 *
	 *  @note If the capture mode is `MiSnapLivenessCaptureMode.kLivenessCaptureMode_Manual`, this flag is not set.
	 *  @see MiSnapLivenessCaptureParameters
	 *  - Since: 1.0
	 */
	kLiveness_Liveness_Success			= 1 << 1,
    
    /**
     *  Liveness Fail - the spoof attack was detected.
     *
     *  - Since: 2.0
     */
    kLiveness_Liveness_Spoof_Detected   = 1 << 2,
    
    /**
     *  Error Face Not Centered - the face is not in the center of a screen
     *
     *  - Since: 2.0
     */
    kLiveness_Error_Face_Not_Centered   = 1 << 3,
    
	/**
	 *  Error Low Lighting - the lighting is beneath the minimum threshold.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Error_Low_Lighting		= 1 << 4,
	
	/**
	 *  Error Too Far - the subject's face is too far from the camera.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Error_Too_Far				= 1 << 5,
	
	/**
	 *  Error Too Near - the subject's face is too near to the camera.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Error_Too_Near			= 1 << 6,
	
	/**
	 *  Error Low Sharpness - the image sharpness is too low.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Error_Low_Sharpness		= 1 << 7,
	
	/**
	 *  Error Device Angle - the device is tilted.
	 *
	 *  - Since: 1.0
	 */
	kLiveness_Error_Device_Tilt			= 1 << 8,
    
    /**
     *  Hold Still - hold the device still while liveness is being verified
     *
     *  - Since: 2.1
     */
    kLiveness_Hold_Still                = 1 << 9,
    
};

/**
 *  `MiSnapLivenessResultCode` defines various result codes return by a session.
 *
 *  - Since: 2.1
 */
typedef NS_ENUM(NSInteger, MiSnapLivenessResultCode)
{
    /**
     *  Result Unverified - auto capture passive liveness NOT detected, active liveness detected
     *
     *  - Since: 2.1
     */
    kLiveness_Result_Unverified = 0,
    
    /**
     *  Result Unverified Still Camera - manual capture passive liveness NOT detected, active liveness NOT detected
     *
     *  - Since: 2.1
     */
    kLiveness_Result_Unverified_Still_Camera,
    
    /**
     *  Result Success Video - auto capture passive liveness detected, active liveness detected
     *
     *  - Since: 2.1
     */
    kLiveness_Result_Success_Video,
    
    /**
     *  Result Success Still Camera - manual capture passive liveness detected, active liveness NOT detected
     *
     *  - Since: 2.1
     */
    kLiveness_Result_Success_Still_Camera,
    
    /**
     *  Result Spoof Detected - auto or manual capture spoof detected
     *
     *  - Since: 2.1
     */
    kLiveness_Result_Spoof_Detected
};

/**
 *  `MiSnapLivenessCaptureResults` stores the video frame analysis.  The contents
 *  of this class should be considered volatile as the data members are set
 *  from various background threads and aggregated by this class.
 *
 *  Results are returned as a delegate parameter by the `MiSnapLivenessCaptureView`
 *  when a frame is analyzed as a static copy of 'current' parameters.
 *
 *  Because this structure is set from a background thread, data elements are
 *  set atomically as a bit-field.  Multiple conditions could exist in a given
 *  frame.  Example: lighting is beneath the host-configured threshold, but liveness
 *  was detected.
 *
 *  - Since: 1.0
 */
@interface MiSnapLivenessCaptureResults : NSObject <NSCopying>

/**
 *  The captured image that meets or exceeds the capture parameter thresholds.
 *  This property is nil until a capture occurs.
 *
 *  - Since: 1.0
 */
@property (nonatomic, strong, readonly) UIImage *capturedImage;

/**
 *  The encoded image (derived from the capturedImage property).
 *  This property is nil until a capture occurs.
 *
 *  - Since: 1.0
 */
@property (nonatomic, strong, readonly) NSString *encodedImage;

/**
 *  The liveness result code
 *  See MiSnapLivenessResultCode enum for all available result codes
 *
 *  - Since: 2.1
 */
@property (nonatomic, assign, readonly) MiSnapLivenessResultCode livenessResultCode;

/**
 *  A JSON formatted string containing user-experience-data.
 *  This property is nil until a capture occurs.
 *
 *  - Since: 1.0
 */
@property (nonatomic, strong, readonly) NSString *uxpData;

/**
 *  The most recent video frame result.  Various conditions may be simultaneously
 *  present for a given image.  If `MiSnapLivenessResultType.kLiveness_Liveness_Success` is TRUE, the
 *  subject was determined to be sufficiently "live" - despite other the host
 *  configured threshold values being met.
 *
 *  - Since: 1.0
 */
@property (atomic, assign, readonly) MiSnapLivenessResultType analysisFlags;

/**
 *  Returns `TRUE` if liveness and a face was detected with no other errors.
 *
 *  @return `TRUE` if the current analysis results can be captured, `FALSE` otherwise
 *
 *  - Since: 1.0
 */
- (BOOL)canCaptureFrame;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if a face is detected in the most recent video frame.
 *
 *  - Since: 1.0
 */
- (BOOL)isFacePresent;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if liveness was detected (blink) in the most recent video frame.
 *
 *  - Since: 1.0
 */
- (BOOL)isLiveDetected;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if spoof was detected in the most recent video frame.
 *
 *  - Since: 1.1
 */
- (BOOL)isSpoofDetected;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if a face is not centered on a screen.
 *
 *  - Since: 2.0
 */
- (BOOL)isErrorFaceNotCentered;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if the lighting value is below a host-set value.
 *
 *  - Since: 1.0
 */
- (BOOL)isErrorLowLighting;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if the subject is too far away from the camera.
 *
 *  - Since: 1.0
 */
- (BOOL)isErrorTooFar;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if the subject is too close to the camera.
 *
 *  - Since: 1.0
 */
- (BOOL)isErrorTooNear;

/**
 *  Convenience method to evaluate the `analysisFlags` property.
 *
 *  @return Returns `TRUE` if the sharpness value is below a host-set value.
 *
 *  - Since: 1.0
 */
- (BOOL)isErrorLowSharpness;

/**
 *  Convenience method to evalute the `analysisFlags` property
 *
 *  @return Returns `TRUE` if the device is tilted too much.
 *
 *  - Since: 1.0
 */
- (BOOL)isErrorDeviceTilt;

/**
 *  Convenience method to evalute the `analysisFlags` property
 *
 *  @return Returns `TRUE` if the device should be held still.
 *
 *  - Since: 2.1
 */
- (BOOL)shouldHoldStill;

@end
