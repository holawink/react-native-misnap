//
//  MiSnapFacialCaptureAnalyzer.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureResults.h>

/**
Defines the smile status modes
The default  mode is None (`MiSnapFacialCaptureSmileStatusNone`).
 
- Since: 3.0.0
*/
typedef NS_ENUM(NSInteger, MiSnapFacialCaptureSmileStatus)
{
    MiSnapFacialCaptureSmileStatusNone = 0,
    MiSnapFacialCaptureSmileStatusTrue,
    MiSnapFacialCaptureSmileStatusFalse
};

/**
 Defines an interface for delegates of MiSnapFacialCaptureAnalyzerDelegate
 
 - Since: 3.0.0
*/
@protocol MiSnapFacialCaptureAnalyzerDelegate <NSObject>

/**
 Called after analysis of each frame
 
 @param results
 A `MiSnapFacialCaptureResults` object with the current frame results.
 
 - Since: 3.0.0
*/
- (void)detectionResults:(MiSnapFacialCaptureResults *)results;

/**
 Called whenever a final frame was selected that meets environmental thresholds defined in `MiSnapFacialCaptureParameters`
 
 @param results
 A `MiSnapFacialCaptureResults` object with a final frame results.
 
 - Since: 3.0.0
*/
- (void)detectionSuccess:(MiSnapFacialCaptureResults *)results;

/**
 Called whenever a user cancels a session
 
 @param results
 A `MiSnapFacialCaptureResults` object with an intermediate frame results.
 
 - Since: 3.0.0
*/
- (void)detectionCancelled:(MiSnapFacialCaptureResults *)results;

/**
 Called when device supports Manual only frame selection (iOS < 12.0)
 
 - Since: 3.0.0
*/
- (void)manualOnly;

/**
 Called when `selectOnSmile` parameter is overridden to `FALSE` and `countdownTime` is greater than or equal to `2` (seconds).
 
 @see
 For more details refer to afore-mentioned properties descriptions in `MiSnapFacialCaptureParameters`
 
 - Since: 3.0.0
*/
- (void)startCountdown;

@end


/**
MiSnapFacialCaptureAnalyzer is a class that defines an interface for controlling analysis of a session.

Delegates of a MiSnapFacialCaptureAnalyzer instance that imlement the MiSnapFacialCaptureAnalyzerDelegate protocol will receive the defined callbacks.
*/
@interface MiSnapFacialCaptureAnalyzer : NSObject

/**
 The delegate that implements the MiSnapFacialCaptureAnalyzerDelegate and that will receive the required protocol methods from MiSnapFacialCaptureAnalyzer
*/
@property (nonatomic, weak) id<MiSnapFacialCaptureAnalyzerDelegate> delegate;

/**
 Creates an instance of MiSnapFacialCaptureAnalyzer
 @param parameters The `MiSnapFacialCaptureParameters` to use
 @return An instance of MiSnapFacialCaptureAnalyzer
*/
- (instancetype)initWithParameters:(MiSnapFacialCaptureParameters *)parameters;

/**
 Pause the frame analysis by MiSnapFacialCaptureAnalyzer for no specific reason. The analyzer can resume again from the paused state.
*/
- (void)pause;

/**
 Pause the frame analysis by MiSnapFacialCaptureAnalyzer for one of the tutorial modes. The analyzer can resume again from the paused state.
 @param tutorialMode `MiSnapFacialCaptureTuturialMode`
*/
- (void)pauseFor:(MiSnapFacialCaptureTuturialMode)tutorialMode;

/**
 Starts the frame analysis or resumes if it was paused
*/
- (void)resume;

/**
 Stops the frame analysis and deinitializes all internal objects. Must be called before deinitializing `MiSnapFacialCaptureAnalyzer`
*/
- (void)stop;

/**
 Returns intermediate results and calls `stop`
*/
- (void)cancel;

/**
 Analyzes a provided `CMSampleBuffer`
 
 @param sampleBuffer  A `CMSampleBuffer` object containing the video frame data and additional information about the frame, such as its format and presentation time.
*/
- (void)analyzeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 Updates `MiSnapFacialCaptureAnalyzer` mode
 
@param mode `MiSnapFacialCaptureMode`
*/
- (void)updateMode:(MiSnapFacialCaptureMode)mode;

/**
 Select the current frame regardless of analysis result
*/
- (void)selectFrame;


@end
