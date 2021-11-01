//
//  MiSnapFacialCaptureResults.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>

/**
 Defines the statuses returned by MiSnapFacialCapture.
 
 - Since: 3.0.0
*/
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureStatus) {
    MiSnapFacialCaptureStatusNone               = 0,
    MiSnapFacialCaptureStatusFaceNotFound       = 1,
    MiSnapFacialCaptureStatusMoreThanOneFace    = 2,
    MiSnapFacialCaptureStatusFaceRoll           = 3,
    MiSnapFacialCaptureStatusFacePitch          = 4,
    MiSnapFacialCaptureStatusFaceYaw            = 5,
    MiSnapFacialCaptureStatusTooFar             = 6,
    MiSnapFacialCaptureStatusTooClose           = 7,
    MiSnapFacialCaptureStatusFaceNotCentered    = 8,
    MiSnapFacialCaptureStatusHoldStill          = 9,
    MiSnapFacialCaptureStatusCountdown          = 10,
    MiSnapFacialCaptureStatusTooDark            = 11,
    MiSnapFacialCaptureStatusNonUniformLight    = 12,
    MiSnapFacialCaptureStatusStopSmiling        = 13,
    MiSnapFacialCaptureStatusGood               = 14
};

/**
 Defines the result codes supported by MiSnapFacialCapture.
 
 - Since: 3.0.0
*/
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureResult)
{
    MiSnapFacialCaptureResultNone = 0,
    MiSnapFacialCaptureResultSuccessStillCamera,
    MiSnapFacialCaptureResultSuccessVideo,
    MiSnapFacialCaptureResultCancelled
};

/**
MiSnapFacialCaptureResults is a class that defines an interface for results returned by the SDK
*/
@interface MiSnapFacialCaptureResults : NSObject

/**
The highest priority status for the current frame
 
Priority order is based on `MiSnapFacialCaptureStatus` enum
*/
@property (nonatomic, readonly) MiSnapFacialCaptureStatus highestPriorityStatus;

/**
An array of ordered statuses for the current frame
 
Priority order is based on `MiSnapFacialCaptureStatus` enum
*/
@property (nonatomic, readonly) NSArray * _Nonnull orderedStatuses;

/**
A `CGRect` rectangle of a face
*/
@property (nonatomic, readonly) CGRect faceRect;

/**
An array of face countour points
*/
@property (nonatomic, readonly) NSArray * _Nullable faceContourPoints;

/**
An array of nose crest points
*/
@property (nonatomic, readonly) NSArray * _Nullable noseCrestPoints;

/**
An array of nose points
*/
@property (nonatomic, readonly) NSArray * _Nullable nosePoints;

/**
An array of left eye points
*/
@property (nonatomic, readonly) NSArray * _Nullable leftEyePoints;

/**
An array of right eye points
*/
@property (nonatomic, readonly) NSArray * _Nullable rightEyePoints;

/**
An array of inner lip points
*/
@property (nonatomic, readonly) NSArray * _Nullable innerLipsPoints;

/**
An array of outer lip points
*/
@property (nonatomic, readonly) NSArray * _Nullable outerLipsPoints;

/**
 An image that was selected based on environmental thresholds defined in `MiSnapFacialCaptureParameters` in `MiSnapFacialCaptureModeAuto` or the frame that was manually selected by a user in `MiSnapFacialCaptureModeManual`
 
 Note: it's `nil` if the current frame doesn't meet environmental thresholds defined in `MiSnapFacialCaptureParameters` in `MiSnapFacialCaptureModeAuto` or not yet selected by a user in `MiSnapFacialCaptureModeManual`
*/
@property (nonatomic, readonly) UIImage * _Nullable selectedImage;

/**
 A base64 encoded representation of a `selectedImage`
 
 Note: it's `nil` if the `selectedImage` is nil
*/
@property (nonatomic, readonly) NSString * _Nullable encodedSelectedImage;

/**
 A MIBI Data string that has analytics for the session
 
 Note it's `nil` unitl a frame is selected
*/
@property (nonatomic, readonly) NSString * _Nullable mibiDataString;

/**
 A result code of a session
 
 @see `MiSnapFacialCaptureResult` enum for all available result codes
*/
@property (nonatomic, readonly) MiSnapFacialCaptureResult resultCode;

/**
 @return A localiize key that can be used by UX to query Localizable.strings file to get a localized string
*/
+ (NSString * _Nonnull)localizeKeyFrom:(MiSnapFacialCaptureStatus)status;

/**
 @param resultCode Result code to get string representation of
 @return A result code in `NSString` format
*/
+ (NSString * _Nonnull)stringFrom:(MiSnapFacialCaptureResult)resultCode;

@end
