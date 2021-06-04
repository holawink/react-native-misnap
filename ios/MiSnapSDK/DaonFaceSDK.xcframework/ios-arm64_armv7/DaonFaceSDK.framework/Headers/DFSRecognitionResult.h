//
//  DFSRecognitionResult
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/15/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString* const kRecognitionResultFaceScoreKey               = @"result.face.recognition.score";
static NSString* const kRecognitionResultFacePositionKey            = @"result.face.position";
static NSString* const kRecognitionResultFacePositionPortraitKey    = @"result.face.position.portrait";
static NSString* const kRecognitionResultFaceErrorKey               = @"result.face.error";


/*!
 @brief Liveness result.
 */
@interface DFSRecognitionResult : NSObject


/*!
 @brief Get the face position.
 */
@property (nonatomic, readonly) CGRect facePosition DEPRECATED_MSG_ATTRIBUTE("Please use faceRectangle.");
@property (nonatomic, readonly) CGRect facePositionPortrait DEPRECATED_MSG_ATTRIBUTE("Renamed to faceRectangle.");

/*!
@brief Get the face rectangle. Coordinates are based on a portrait image.
*/
@property (nonatomic, readonly) CGRect faceRectangle;

/*!
 @brief Get the recognition score.
 @description The score value will be between 0 and 1.
 */
@property (nonatomic, readonly) float score;


/*!
 @brief Initialises a new instance and parses the raw results to populate the class properties.
 @param results The raw results.
 @result A new instance ready.
 */
- (id) initWithResults:(NSDictionary*)results;



@end
