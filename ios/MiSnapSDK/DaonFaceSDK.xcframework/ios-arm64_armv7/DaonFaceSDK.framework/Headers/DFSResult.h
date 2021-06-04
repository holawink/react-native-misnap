//
//  DFSResult.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/11/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <DaonFaceSDK/DFSLivenessResult.h>
#import <DaonFaceSDK/DFSQualityResult.h>
#import <DaonFaceSDK/DFSRecognitionResult.h>


static NSString* const kResultModuleKey         = @"result.module";
static NSString* const kResultModuleListKey     = @"result.module.list";
static NSString* const kResultModuleConfigKey   = @"result.module.config";
static NSString* const kResultModuleErrorKey    = @"result.module.error";
static NSString* const kResultImageKey          = @"result.image";
static NSString* const kResultDeviceUprightKey  = @"result.sensor.device.position.upright";
static NSString* const kResultDeviceGravityXKey = @"result.sensor.device.gravity.x";
static NSString* const kResultDeviceGravityYKey = @"result.sensor.device.gravity.y";
static NSString* const kResultDeviceGravityZKey = @"result.sensor.device.gravity.z";

/*!
 @brief Image Analysis result.
 */
@interface DFSResult : NSObject


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

@property (nonatomic, readonly) NSDictionary * configuration;
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

- (id) objectWithKey:(NSString*)key;

- (DFSResult*) resultWithQualityResult:(DFSQualityResult*)qr;

@end
