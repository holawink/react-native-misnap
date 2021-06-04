//
//  File.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 3/5/14.
//  Copyright (c) 2014 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @header DFSFileTools
 * @discussion The DFSFileTools object provides methods for writing images and text to a file.
 */

@interface DFSFileTools : NSObject

/*!
 * @abstract Write a CVPixelBuffer to a file as a JPG image.
 * @param buffer The pixel buffer reference
 * @param name The file name
 * @discussion An image object is created from the contents of the CVPixelBuffer reference and
 * then converted to JPG and written to the Image folder in the applications documents folder.
 */
+ (void) writePixelBuffer:(CVPixelBufferRef)buffer withName:(NSString*)name;

/*!
 * @abstract Write an image object to a file as a JPG image.
 * @param image The image object
 * @param name The file name
 * @discussion The image object is converted to JPG and written to the Image folder in the applications documents folder.
 */
+ (void) writeImage:(UIImage*)image withName:(NSString*)name;

/*!
 * @abstract Write a string to file.
 * @param text The text
 * @param name The file name
 * @discussion The string is written to the Data folder in the applications documents folder.
 */
+ (void) writeText:(NSString*)text withName:(NSString*)name;

/*!
 * @abstract Write an NSData object to a file
 * @param data The NSData object
 * @param folder The folder
 * @param name The file name
 */
+ (void) writeData:(NSData*)data folder:(NSString*)folder name:(NSString*)name;

+ (NSString*) writeTemporaryData:(NSData*)data name:(NSString*)name;

+ (NSData*) readTemporaryDataWithName:(NSString*)name;

+ (void) clearTemporaryData;

+ (BOOL) removeItemAtPath:(NSString*)path;

@end
