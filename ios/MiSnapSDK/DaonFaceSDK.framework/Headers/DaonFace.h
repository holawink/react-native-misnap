//
//  DaonFace.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/10/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "DFSEnrollDelegate.h"
#import "DFSRecognitionDelegate.h"
#import "DFSAnalysisDelegate.h"
#import "DFSAnalyzerProtocol.h"
#import "DFSRecognizerProtocol.h"

/*!
 @brief SDK Interface for liveness detection, verification and/or quality measures.
 */
@interface DaonFaceSDK : NSObject

@property (nonatomic, assign) BOOL consolidateResults;
@property (nonatomic, assign) BOOL currentFrameInResult;

@property (nonatomic, readonly) NSString * license;
@property (nonatomic, readonly) NSString * organization;
@property (nonatomic, readonly) NSDictionary * extensions;

/*!
 @functiongroup Initialisation
 */

/*!
 @brief Initialises a new instance.
 @param license The license data. If the license string is nil, the SDK will look in the main bundle for a license.txt file.
 @result A new instance ready to be use for analysis / verification.
 */
- (id) initWithLicense:(NSString*)license;

- (id) initWithRecognizer:(id<DFSRecognizerProtocol>)recognizer license:(NSString*)license;

/*!
 @functiongroup Version Information
 */

/*!
 @brief Get version.
 */
- (NSString*) version;

/*!
 @functiongroup Configuration
 */

/*!
 @brief Get version.
 */
- (void) addAnalyzer:(id<DFSAnalyzerProtocol>)analyzer;

/*!
 @brief Get version.
 */
- (void) removeAnalyzer:(id<DFSAnalyzerProtocol>)analyzer;


/*!
 @brief Set configuration.
 @description Provides a means of passing customization parameters such as Head Movement threshold to the SDK
 via a dictionary of key-value pairs (See "Configuration keys"). Ideally this method should be used after
 initWithOptions: is called but before any image is passed to an enroll/analyze method.
 @param configuration The new configuration
 */
- (void) setConfiguration:(NSDictionary*)configuration;


/*!
 @functiongroup Processing - Single image
 */

/*
 @brief Create a template for an image.
 @description This method is currently only supported when using the DaonFaceMatcher module.
 @param image The image to enroll.
 @param error An error object
 @param orientation The AVCaptureVideoOrientation
 */
- (NSData*) templateWithImage:(UIImage*)image error:(NSError**)error;
- (NSData*) templateWithPixelBuffer:(CVPixelBufferRef)buffer error:(NSError **)error;
- (NSData*) templateWithPixelBuffer:(CVPixelBufferRef)buffer orientation:(AVCaptureVideoOrientation)orientation error:(NSError **)error;

- (float) matchWithImage:(UIImage*)image template:(NSData*)tmplate error:(NSError**)error;

/*!
 @brief Analyzes a singe static UIImage (e.g from UIImagePickerController).
 @param image The UIImage (RGBA) to analyze.
 @param completion The completion block that will be called with the result of the analysis.
 */
- (void) analyzeSingleImage:(UIImage*)image completion:(void (^)(NSDictionary* response))completion;
- (void) analyzeSingleImage:(UIImage*)image withDelegate:(id<DFSAnalysisDelegate>)delegate;
- (NSDictionary*) analyzeSingleImage:(UIImage*)image;

/*!
 @functiongroup Processing - Image from video steam
 */

/*!
 @brief Analyzes an image buffer from a video stream.
 @param image The CVPixelBufferRef to analyze.
 @param delegate The delegate that will be called back with the result of the analysis.
 */
- (void) analyzeImage:(CVPixelBufferRef)image withDelegate:(id<DFSAnalysisDelegate>)delegate;

/*!
 @brief Analyzes an image buffer from a video stream.
 @param image The CVPixelBufferRef to analyze.
 @param orientation The AVCaptureVideoOrientation
 @param delegate The delegate that will be called back with the result of the analysis.
 */
- (void) analyzeImage:(CVPixelBufferRef)image orientation:(AVCaptureVideoOrientation)orientation delegate:(id<DFSAnalysisDelegate>)delegate;
                                                                                                  
/*!
 @functiongroup Control
 */

/*!
 @brief Stop and release resources.
 */
- (void) stop;

/*!
 @brief Start after a stop or reset.
 */
- (void) start;

/*!
 @brief Reset and clear enrolled data.
 */
- (void) reset;

@end
