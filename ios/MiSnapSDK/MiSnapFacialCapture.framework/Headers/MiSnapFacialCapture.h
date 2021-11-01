//
//  MiSnapFacialCapture.h
//  MiSnapFacialCapture
//
//  Created by Stas Tsuprenko on 1/12/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureParameters.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureResults.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureAnalyzer.h>
#import <MiSnapFacialCapture/MiSnapFacialCaptureCamera.h>

/**
 An umbrella header for all SDK classes
 
 - Since: 3.0.0
*/

@interface MiSnapFacialCapture : NSObject

/**
 Returns MiSnapFacialCapture version
 
 - Since: 3.0.0
*/
+ (NSString * _Nonnull)version;

@end
