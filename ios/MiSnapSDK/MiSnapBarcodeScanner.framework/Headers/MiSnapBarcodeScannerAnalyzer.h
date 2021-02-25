//
//  MiSnapBarcodeScannerAnalyzer.h
//  MiSnapBarcodeScanner
//
//  Created by Stas Tsuprenko on 4/11/18.
//  Copyright © 2018 miteksystems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MiSnapBarcodeScannerAnalyzerDelegate <NSObject>

- (void)analyzerDecodeResultString:(NSString *)decodeResultString image:(UIImage *)image;

@end

@interface MiSnapBarcodeScannerAnalyzer : NSObject

@property (nonatomic) id <MiSnapBarcodeScannerAnalyzerDelegate> delegate;

- (void)analyzeSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
