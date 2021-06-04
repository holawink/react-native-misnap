//
//  QualityAnalyzer.h
//  DaonFaceSDK
//
//  Copyright © 2017 Daon. All rights reserved.
//

#import <DaonFaceSDK/DFSLicensedAnalyzer.h>

#define kDFSConfigQualityTrackingKey @"QualityTracking"
#define kDFSConfigQualityFrameRateKey @"QualityFramerate"

#define kDFSConfigQualityThresholdFaceFoundKey         @"QualityThresholdFaceFound"
#define kDFSConfigQualityThresholdFaceOneOnlyKey       @"QualityThresholdFaceOneOnly"
#define kDFSConfigQualityThresholdFaceAngleKey         @"QualityThresholdFaceAngle"
#define kDFSConfigQualityThresholdFaceFrontalKey       @"QualityThresholdFaceFrontal"
#define kDFSConfigQualityThresholdEyesFoundKey         @"QualityThresholdEyesFound"
#define kDFSConfigQualityThresholdEyesOpenKey          @"QualityThresholdEyesOpen"
#define kDFSConfigQualityThresholdEyeDistanceKey       @"QualityThresholdEyeDistance"
#define kDFSConfigQualityThresholdLightingKey          @"QualityThresholdLighting"
#define kDFSConfigQualityThresholdSharpnessKey         @"QualityThresholdSharpness"
#define kDFSConfigQualityThresholdExposureKey          @"QualityThresholdExposure"
#define kDFSConfigQualityThresholdGrayscaleDensityKey  @"QualityThresholdGrayscaleDensity"
#define kDFSConfigQualityThresholdScoreKey             @"QualityThresholdScore"
#define kDFSConfigQualityThresholdMinFaceSizeKey       @"QualityThresholdMinFaceSize"

@interface DFSQualityAnalyzer : NSObject <DFSLicensedAnalyzer>

+ (NSString*) module;

@end
