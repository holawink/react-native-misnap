//
//  DFSRecognizerAnalyzer
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 5/4/16.
//  Copyright © 2016 Daon. All rights reserved.
//

#import <DaonFaceSDK/DFSLicensedAnalyzer.h>
#import <DaonFaceSDK/DFSRecognizerProtocol.h>

@interface DFSRecognizerAnalyzer : NSObject <DFSLicensedAnalyzer, DFSRecognizerProtocol>

+ (NSString*) module;

@end

