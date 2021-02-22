//
//  DFSLivenessBlinkAnalyzer
//  DaonFaceSDK
//
//  Copyright © 2017 Daon. All rights reserved.
//
//

#import <DaonFaceSDK/DaonFaceSDK.h>

// setConfiguration key
#define kDFSConfigBlinkDetectionThresholdKey @"BlinkDetectionThreshold"


@interface DFSLivenessBlinkAnalyzer : NSObject <DFSLicensedAnalyzer>

+ (NSString *) module;

@end
