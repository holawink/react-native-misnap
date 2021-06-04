//
//  DFSAnalysisDelegate.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/11/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#import <CoreVideo/CVPixelBuffer.h>
#import <UIKit/UIKit.h>

#import <DaonFaceSDK/DFSResult.h>

/*!
 @brief Delegate for feedback on image analysis.
 */
@protocol DFSAnalysisDelegate <NSObject>

/*!
 @brief Called when analysis has completed for a particular UIImage.
 @param result The analysis result.
 */
- (void) analysisResult:(NSDictionary*)result;


@end


/*!
 @brief Liveness Delegate
 */
@protocol DFSLivenessAnalysisDelegate <NSObject>

- (void) result:(DFSResult*)result didChangeState:(LivenessState)state;
- (void) result:(DFSResult*)result shouldDisplayAlert:(LivenessAlert)alert;

@optional

- (void) result:(DFSResult*)result didUpdateState:(LivenessState)state;

@end

