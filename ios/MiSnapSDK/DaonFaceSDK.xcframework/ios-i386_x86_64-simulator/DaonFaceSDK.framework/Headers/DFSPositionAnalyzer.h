//
//  DFSPositionAnalyzer.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 9/12/17.
//  Copyright © 2017 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DaonFaceSDK/DFSAnalyzerProtocol.h>

#define kDFSConfigSensorPitchMinimumKey @"PositionSensorPitchMinimum"
#define kDFSConfigSensorPitchMaximumKey @"PositionSensorPitchMaximum"

static double const kSensorPitchMin  = 75.0;
static double const kSensorPitchMax  = 90.0;



@interface DFSPositionAnalyzer : NSObject <DFSAnalyzerProtocol>

+ (NSString*) module;

@end
