//
//  Analyzer.h
//  DaonFaceSDK
//
//  Copyright © 2015-18 Daon. All rights reserved.
//

#ifndef Analyzer_h
#define Analyzer_h

#import <CoreVideo/CVPixelBuffer.h>
#import <UIKit/UIKit.h>

#import "DFSModuleProtocol.h"


@protocol DFSAnalyzerProtocol <DFSModuleProtocol>

// Image from video stream
- (void) shouldAnalyzeImageData:(NSData*_Nonnull)buffer
                      timestamp:(long long)ms
                        results:(NSDictionary*_Nonnull)results
                     completion:(void (^_Nonnull)(NSDictionary*_Nullable response))completion;

- (void) shouldAnalyzeSingleImageData:(NSData*_Nonnull)buffer
                              results:(NSDictionary*_Nonnull)results
                           completion:(void (^_Nonnull)(NSDictionary*_Nullable response))completion;

@end

#endif /* Analyzer_h */
