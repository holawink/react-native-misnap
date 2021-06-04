//
//  DFSLiveness3DAnalyzer.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 7/25/19.
//  Copyright © 2019 Daon. All rights reserved.
//

#import <DaonFaceSDK/DaonFaceSDK.h>

NS_ASSUME_NONNULL_BEGIN

// Remove
#define kDFSConfigLivenessMaxDurationKey @"LivenessDurationMax"
#define kDFSConfigLivenessMinDurationKey @"LivenessDurationMin"

#define kDFSConfigLivenessDurationKey @"LivenessDuration"
#define kDFSConfigLivenessStartDelayKey @"LivenessStartDelay"
#define kDFSConfigLivenessSpoofExtendedDetectionKey @"LivenessSpoofExtendedDetection"
#define kDFSConfigLivenessSpoofContinuityKey @"LivenessSpoofContinuity"

#define kDFSConfigLivenessTemplateKey @"LivenessTemplate"
#define kDFSConfigLivenessTemplateContinuityKey @"LivenessTemplateContinuity"
#define kDFSConfigLivenessTemplateQualityKey @"LivenessTemplateQuality"

@interface DFSLiveness3DAnalyzer : NSObject <DFSLicensedAnalyzer>

+ (NSString*) module;

@end

@interface DFSLivenessAnalysisHandler : NSObject <DFSAnalysisDelegate>

- (id) initWithDelegate:(id<DFSLivenessAnalysisDelegate>)delegate;
- (void) parseResult:(NSDictionary *)result;

@end

NS_ASSUME_NONNULL_END
