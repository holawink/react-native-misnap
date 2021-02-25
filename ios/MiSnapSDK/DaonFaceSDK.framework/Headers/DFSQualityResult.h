//
//  DFSQualityResult.h
//  DaonFaceSDK
//
//  Copyright © 2017 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kQualityResultFaceFoundKey         = @"result.face.found";
static NSString* const kQualityResultFaceFoundOneOnlyKey  = @"result.face.found.one";
static NSString* const kQualityResultFaceContinuityKey    = @"result.face.continuity";
static NSString* const kQualityResultFaceFrontalKey       = @"result.face.frontal";
static NSString* const kQualityResultFaceAngleKey         = @"result.face.angle";
static NSString* const kQualityResultEyesFoundKey         = @"result.face.eye";
static NSString* const kQualityResultEyesOpenKey          = @"result.face.eye.open";
static NSString* const kQualityResultUniformLightingKey   = @"result.face.lighting";
static NSString* const kQualityResultEyeDistanceKey       = @"result.face.eye.distance";
static NSString* const kQualityResultSharpnessKey         = @"result.face.sharpness";
static NSString* const kQualityResultExposureKey          = @"result.face.exposure";
static NSString* const kQualityResultGrayscaleDensityKey  = @"result.face.grayscale.density";
static NSString* const kQualityResultGlobalKey            = @"result.face.global";

// Confidence score
static NSString* const kQualityResultFaceFoundScoreKey          = @"result.face.found.score";
static NSString* const kQualityResultFaceFoundOneOnlyScoreKey   = @"result.face.found.one.score";
static NSString* const kQualityResultFaceContinuityScoreKey     = @"result.face.continuity.score";
static NSString* const kQualityResultFaceFrontalScoreKey        = @"result.face.frontal.score";
static NSString* const kQualityResultFaceAngleScoreKey          = @"result.face.angle.score";
static NSString* const kQualityResultEyesFoundScoreKey          = @"result.face.eye.score";
static NSString* const kQualityResultEyesOpenScoreKey           = @"result.face.eye.open.score";
static NSString* const kQualityResultUniformLightingScoreKey    = @"result.face.lighting.score";
static NSString* const kQualityResultEyeDistanceScoreKey        = @"result.face.eye.distance.score";
static NSString* const kQualityResultSharpnessScoreKey          = @"result.face.sharpness.score";
static NSString* const kQualityResultExposureScoreKey           = @"result.face.exposure.score";
static NSString* const kQualityResultGrayscaleDensityScoreKey   = @"result.face.grayscale.density.score";
static NSString* const kQualityResultGlobalScoreKey             = @"result.face.global.score";

static NSString* const kQualityResultFacePositionKey            = @"result.quality.face.position";
static NSString* const kQualityResultFacePositionPortraitKey    = @"result.quality.face.position.portrait";


/*!
 @brief Image quality measures.
 */
@interface DFSQualityResult : NSObject


/*!
 @brief Check if a face is found.
 */
@property (nonatomic, readonly) BOOL hasFace;

/*!
 @brief Check if more than one face is found. Only for single image analysis.
 */
@property (nonatomic, readonly) BOOL hasOneFaceOnly;

/*!
 @brief Check for face continuity. Use this to ensure that the user face has not been swapped out during an authentication session
 */
@property (nonatomic, readonly) BOOL hasFaceContinuity;

/*!
 @brief Eyes found.
 @description This value is heavily impacted by eye glasses and lighting and may often produce false negatives.
 */
@property (nonatomic, readonly) BOOL hasEyes;

/*!
 @brief Eyes open.
 @description This value is heavily impacted by eye glasses and lighting and may often produce false negatives.
 */
@property (nonatomic, readonly) BOOL hasEyesOpen;

/*!
 @brief Has uniform lighting.
 */
@property (nonatomic, readonly) BOOL hasUniformLighting;

/*!
 @brief Eye distance is within thresholds.

 */
@property (nonatomic, readonly) BOOL hasAcceptableEyeDistance;

/*!
 @brief Get distance between eyes.
 @description Distance in pixels between the eyes.
 */
@property (nonatomic, readonly) NSInteger eyeDistance;

/*!
 @brief Face/pose angle is within thresholds.
 */
@property (nonatomic, readonly) BOOL hasAcceptableFaceAngle;

/*!
 @brief Image sharpness is within thresholds
 */
@property (nonatomic, readonly) BOOL hasAcceptableSharpness;

/*!
 @brief Image exposure is within thresholds.
 */
@property (nonatomic, readonly) BOOL hasAcceptableExposure;

/*!
 @brief Grayscale density and detail is within thresholds.
 */
@property (nonatomic, readonly) BOOL hasAcceptableGrayscaleDensity;


/*!
 @brief the global quality score is within thresholds.
 @description The global score is derived from an aggregate value of all other scores. This field
 is recommended for determining whether an image is of sufficient quality.
 */
@property (nonatomic, readonly) BOOL hasAcceptableQuality;

/*!
 @brief Global quality score.
 @description The global score is derived from an aggregate value of all other scores. This field
 is recommended for determining whether an image is of sufficient quality.
 */
@property (nonatomic, readonly) float score;

/*!
 @brief Get the overall quality score for the frame,
 @description bestImageScore = EyesFoundConfidence * EyesOpenConfidence + Global Quality Score
 */
@property (nonatomic, readonly) float bestImageScore;

- (BOOL) hasData;
- (NSDictionary*) results;
/*!
 @brief Initialises a new instance and parses the raw results to populate the class properties.
 @param results The raw results.
 @result A new instance ready.
 */
- (id) initWithResults:(NSDictionary*)results;


////////////////////////////////////////////////
// Backwards compatibility
////////////////////////////////////////////////

/*!
 @brief Get face found confidence.
 */
@property (nonatomic, readonly) float faceFoundConfidence;

/*!
 @brief Get face frontal pose confidence.
 @description This value is heavily impacted by lighting and may often produce false negatives. This
 is being worked on for future releases.
 */
@property (nonatomic, readonly) float frontalPoseConfidence;

/*!
 @brief Get eyes found confidence.
 @description This value is heavily impacted by eye glasses and lighting and may often produce false negatives. This
 is being worked on for future releases.
 */
@property (nonatomic, readonly) float eyesFoundConfidence;

/*!
 @brief Get eyes open confidence.
 @description This value is heavily impacted by eye glasses and lighting and may often produce false negatives. This
 is being worked on for future releases.
 */
@property (nonatomic, readonly) float eyesOpenConfidence;

/*!
 @brief Get uniform lighting confidence.
 */
@property (nonatomic, readonly) float uniformLightingConfidence;

/*!
 @brief Get pose angle.
 */
@property (nonatomic, readonly) NSInteger poseAngleRoll;

/*!
 @brief Get image sharpness.
 */
@property (nonatomic, readonly) NSInteger sharpness;

/*!
 @brief Get image exposure.
 */
@property (nonatomic, readonly) NSInteger exposure;

/*!
 @brief Get grayscale density and detail.
 */
@property (nonatomic, readonly) NSInteger grayscaleDensity;


@end
