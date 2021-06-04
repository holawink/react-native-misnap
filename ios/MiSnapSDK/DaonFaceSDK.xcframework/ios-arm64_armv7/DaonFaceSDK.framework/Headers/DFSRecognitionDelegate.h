//
//  DFSRecognitionDelegate.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 8/4/16.
//  Copyright © 2016 Daon. All rights reserved.
//

#ifndef DFSRecognitionDelegate_h
#define DFSRecognitionDelegate_h


/*!
 @brief Delegate for feedback on recognition.
 */
@protocol DFSRecognitionDelegate <NSObject>

/*!
 @brief Called when verification has completed for a particular UIImage.
 @param result The recognition result.
 */
- (void) recognitionResult:(NSDictionary*)result;


@end

#endif /* DFSRecognitionDelegate_h */
