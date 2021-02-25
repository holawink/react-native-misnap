//
//  MiSnapLiveness.h
//  MiSnapLiveness
//
//  Created by Jeremy Jessup on 3/25/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiSnapLiveness/MiSnapLivenessCaptureView.h>
#import <MiSnapLiveness/MiSnapLivenessCaptureParameters.h>
#import <MiSnapLiveness/MiSnapLivenessCaptureResults.h>
#import <MiSnapLiveness/MiSnapLivenessImageUtils.h>

/**
 *  The MiSnapLiveness framework analyzes a real-time video stream from
 *  a camera input and attempts to recognize facial features and subject
 *  liveness.
 *
 *  The framework defines three main objects:
 *
 *  * `MiSnapLivenessCaptureView`
 *  * `MiSnapLivenessCaptureParameters`
 *  * `MiSnapLivenessCaptureResults`
 *
 *  The host application should create and embed a capture view in their
 *  view hierarchy.  When creating the view, optional capture parameters
 *  can be provided to customize detection.  The capture view also defines
 *  a protocol to allow host application to receive capture results.
 *
 *  - Since: 1.0
 */
@interface MiSnapLiveness : NSObject

/**
 *  Returns the version number of the MiSnapLiveness Framework
 *
 *  @return An NSString containing the major.minor version number
 *
 *  - Since: 1.0
 */
+ (NSString *)sdkVersion;

/**
 *  Returns the name of the MiSnapLiveness Framework
 *
 *  @return An NSString containing the name of the framework
 *
 *  - Since: 1.0
 */
+ (NSString *)sdkName;

@end
