//
//  DFSResult.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/11/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFSLivenessResult;
@class DFSQualityResult;
@class DFSRecognitionResult;

static NSString* const kResultModuleKey         = @"result.module";
static NSString* const kResultModuleListKey     = @"result.module.list";
static NSString* const kResultImageKey          = @"result.image";
static NSString* const kResultDeviceUprightKey  = @"result.sensor.device.position.upright";

/*!
 @brief Image Analysis result.
 */
@interface DFSResult : NSObject


/*!
 @brief Check if a face is found.
 */
@property (nonatomic, readonly) BOOL isFaceFound;

/*!
 @brief Check if the face is being tracked. Use this to ensure that the user face has not been swapped out during an authentication session.
 */
@property (nonatomic, readonly) BOOL isTrackingFace;

/*!
 @brief Check if device is in a upright position.
 @description This can be used to get a better frontal face image, e.g. by
 avoiding that users are looking down at their device when enrolling
 or verifying.
 */
@property (nonatomic, readonly) BOOL isDeviceUpright;

@property (nonatomic, readonly) UIImage * image;

@property (nonatomic, readonly) NSString * module;

@property (nonatomic, readonly) NSArray * modules;

/*!
 @brief Get liveness result.
 */
@property (nonatomic, readonly) DFSLivenessResult * liveness;

/*!
 @brief Get quality result.
 */
@property (nonatomic, readonly) DFSQualityResult * quality;

/*!
 @brief Get recognition result.
 */
@property (nonatomic, readonly) DFSRecognitionResult * recognition;


/*!
 @brief Initialises a new instance and converts the raw results into concrete result objects for liveness, quality and recognition.
 @param results The raw results.
 @result A new instance ready.
 */
- (id) initWithResults:(NSDictionary*)results;


@end
