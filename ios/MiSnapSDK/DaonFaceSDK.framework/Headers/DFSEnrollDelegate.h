//
//  DFSEnrollDelegate.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/11/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <CoreVideo/CVPixelBuffer.h>
#import <UIKit/UIKit.h>

/*!
 @brief Delegate for feedback on image enrollment.
 */
@protocol DFSEnrollDelegate <NSObject>

/*!
 @brief Called when image enrollment has completed for a particular UIImage.
 @param image The image that was enrolled.
 */
- (void) enrollSucceededForImage:(UIImage*)image;

/*!
 @brief Called when image enrollment has completed for a particular CVPixelBufferRef.
 @param imageBuffer The image buffer that was enrolled.
 */
//- (void) enrollSucceededForImageBuffer:(CVPixelBufferRef)imageBuffer;

/*!
 @brief Called when image enrollment has failed for a particular UIImage.
 @param image The image that could not be enrolled.
 */
- (void) enrollFailedForImage:(UIImage*)image withMessage:(NSString*)message;


@end