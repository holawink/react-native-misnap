//
//  MiSnapLivenessImageUtils.h
//  MiSnapLiveness
//
//  Created by Jeremy Jessup on 4/18/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  This class defines some helpful image conversion utilities.
 *
 *  - Since: 1.0
 */
@interface MiSnapLivenessImageUtils : NSObject

/**
 *  Creates a `UIImage` from a pixel buffer object.
 *
 *  @param pixelBuffer Source data of an image
 *
 *  @return A `UIImage` representing the image data
 *
 *  - Since: 1.0
 */
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 *  Creates a `UIImage` from a pixel buffer object and rotates it.
 *
 *  @param pixelBuffer Source data of an image
 *  @param radians     Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A `UIimage` representing the image data
 *
 *  - Since: 1.0
 */
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer withRotation:(double)radians;

/**
 *  Rotates a `UIImage`.
 *
 *  @param image Source image
 *  @param radians     Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A `UIimage` representing the image data
 *
 *  - Since: 1.2
 */
+ (UIImage *)imageFromImage:(UIImage *)image withRotation:(double)radians;

/**
 *  Returns the raw pixel buffer of an image.
 *
 *  @param image Source image in 32-bit ARGB format.
 *
 *  @return A CVImageBufferRef (aka CVPixelBufferRef) containing the image data.
 *
 *  @since 1.0
 */
+ (CVImageBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

/**
 *  Rotates a `CGImageRef` by a specified number of radians
 *
 *  @param image   Source image to rotate
 *  @param radians Rotation amount must be 0, PI/2, PI, -PI/2
 *
 *  @return A new `CGImageRef` that contains the rotated image
 *
 *  - Since: 1.0
 */
+ (CGImageRef)rotateCGImage:(CGImageRef)image byRadians:(double)radians;

/**
 *  Writes a `UIImage` as a JPG to a file.
 *
 *  @param image The image.
 *  @param name  The filename.
 *
 *  - Since: 1.0
 */
+ (void)writeImage:(UIImage *)image withName:(NSString *)name;


@end
