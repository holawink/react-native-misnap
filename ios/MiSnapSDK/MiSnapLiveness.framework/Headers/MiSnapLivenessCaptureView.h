//
//  MiSnapLivenessCaptureView.h
//  MiSnapLiveness
//
//  Created by Jeremy Jessup on 3/30/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declarations
@class MiSnapLivenessCaptureParameters;
@class MiSnapLivenessCaptureResults;

/**
 *  Delegate to receive data from the live video analysis.
 *
 *  - Since: 1.0
 */
@protocol MiSnapLivenessCaptureViewDelegate <NSObject>

@required
/**
 *  When a video frame is analyzed, the results are returned to the caller.
 *  This call is made on the main thread.
 *
 *  @param results     The results of the analysis excluding the captured and encoded image.
 * 
 *  @see `MiSnapLivenessCaptureResults`
 *  - Since: 1.0
 */
- (void)livenessResults:(MiSnapLivenessCaptureResults *)results;

/**
 *  When a video frame meets or exceeds the capture parameter thresholds for 
 *  liveness, it is captured encoded in a base-64 format.
 *  This call is made on the main thread.
 *
 *  @param results       The final analysis results including a captured and encoded image.
 *
 *  @see `MiSnapLivenessCaptureResults`, `MiSnapLivenessCaptureParameters`
 *  - Since: 1.0
 */
- (void)livenessCaptureSuccess:(MiSnapLivenessCaptureResults*)results;

/**
 *  If liveness is not detected after the `MiSnapLivenessCaptureParameters.timeout` elapses,
 *  delegates will receive this notification.  The view does not `shutdown` automatically.
 *  This call is made on the main thread.
 *
 *  @note If the `MiSnapLivenessCaptureView` is set to manual capture, this method is not called.
 *  @see `MiSnapLivenessCaptureParameters`
 *  - Since: 1.0
 */
- (void)livenessTimeout;
@end

/**
 *  This view hosts the AVFoundation video stream and capture session.
 *  In a view hierarchy, an instance of this object should be placed on the "bottom"
 *  so other elements can be layered above it and rendered appropriately.
 *
 *  - Since: 1.0
 */
@interface MiSnapLivenessCaptureView : UIView

/**
 *  The parameters to use as thresholds when analyzing a captured video frame.
 *  Setting this property is optional.  If not provided, default values are used.
 *  This property should be set prior to calling `start`.
 * 
 *  @see `MiSnapLivenessCaptureParameters`
 *  - Since: 1.0
 */
@property (nonatomic, strong) MiSnapLivenessCaptureParameters *captureParams;

/**
 *  Instances interested in the video stream analysis results should implement the protocol.
 *
 *  @see `MiSnapLivenessCaptureViewDelegate`
 *  - Since: 1.0
 */
@property (nonatomic, strong) id<MiSnapLivenessCaptureViewDelegate> delegate;

/**
 *  Starts the video session and begins analysis of frames.
 *
 *  - Since: 1.0
 */
- (void)start;

/**
 *  Stops the video session and terminates analysis.
 *
 *  - Since: 1.0
 */
- (void)shutdown;

/**
 *  Instructs the view to capture the current video frame.  
 *  The results are returned to the delegate in `[livenessCaptureSuccess:]` protocol method.
 *
 *  - Since: 1.0
 */
- (void)manualCaptureFrame;

/**
 *  The license key of the MiSnapLiveness Framework
 *
 *  - Since: 1.1
 */
@property (nonatomic, strong) NSString *licenseKey;

@end
