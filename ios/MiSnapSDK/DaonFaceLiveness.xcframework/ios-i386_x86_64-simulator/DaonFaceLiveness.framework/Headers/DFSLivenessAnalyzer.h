//
//  DFSLivenessAnalyzer
//  DaonFaceSDK
//
//  Copyright © 2017 Daon. All rights reserved.
//

#import <DaonFaceSDK/DaonFaceSDK.h>

/** Liveness security level */
#define kDFSConfigLivenessSecurityLevelKey @"LivenessSecurityLevel"

/** Eyes open security level */
#define kDFSConfigLivenessEyesOpenSecurityLevelKey @"LivenessSecurityLevelEyesOpen"

/** Eyes open detection */
#define kDFSConfigLivenessEyesOpenDetectionKey @"LivenessEyesOpenDetection"


@interface DFSLivenessAnalyzer : NSObject <DFSLicensedAnalyzer>

+ (NSString*) module;

@end
