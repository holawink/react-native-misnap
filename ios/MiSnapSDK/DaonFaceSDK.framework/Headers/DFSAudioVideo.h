//
//  AudioVideo.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 3/5/14.
//  Copyright (c) 2014 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*!
 * @header DFSAudioVideo
 * @discussion Default implementation of an AVFoundation capture session.
 */
@interface DFSAudioVideo : NSObject

/*!
 * @abstract Create an AVCaptureSession object.
 * @param delegate The buffer delegate
 * @return An AVCaptureSession object.
 * @discussion This function returns an AVFoundation capture session using YUV (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) and preset
 * AVCaptureSessionPreset640x480.
 */
+ (AVCaptureSession*) captureSessionWithBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;

+ (AVCaptureSession*) captureSessionWithPreset:(AVCaptureSessionPreset)preset bufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)delegate;
@end
