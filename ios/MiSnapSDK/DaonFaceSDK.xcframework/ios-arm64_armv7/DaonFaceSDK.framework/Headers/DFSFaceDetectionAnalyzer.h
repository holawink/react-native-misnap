//
//  FaceDetectionAnalyzer.h
//  DaonFaceSDK
//
//  Copyright © 2020 Daon. All rights reserved.
//

#import <DaonFaceSDK/DFSLicensedAnalyzer.h>

#define kDFSConfigQualityThresholdFaceMaskKey         @"QualityThresholdFaceMask"

@interface DFSFaceDetectionAnalyzer : NSObject <DFSLicensedAnalyzer>

+ (NSString*) module;

@end
