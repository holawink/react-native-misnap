//
//  RecognizerProtocol.h
//  DaonFaceSDK
//
//  Created by Coulter, Iain on 02/12/2015.
//  Copyright © 2015 Daon. All rights reserved.
//

#ifndef Recognizer_h
#define Recognizer_h

#import <CoreVideo/CVPixelBuffer.h>

#import <DaonFaceSDK/DFSModuleProtocol.h>

//@protocol DFSEnrollDelegate;
//@protocol DFSRecognitionDelegate;

@class UIImage;

@protocol DFSRecognizerProtocol <DFSModuleProtocol>

- (NSData*) templateWithImageData:(NSData*)data size:(CGSize)size error:(NSError**)error;
- (float) matchWithImageData:(NSData*)data template:(NSData*)tmplate size:(CGSize)size error:(NSError**)error;
- (float) matchWithTemplateData:(NSData*)data template:(NSData*)tmplate error:(NSError**)error;

@end

#endif /* Recognizer_h */
