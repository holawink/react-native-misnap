//
//  FSPLicenseManager.h
//  
//
//  Copyright (c) 2013 Daon. All rights reserved.
//

#ifndef FSPLicenseManager_h
#define FSPLicenseManager_h

#import <Foundation/Foundation.h>

static NSString * const kFeatureBlink          = @"blink";
static NSString * const kFeatureHMD            = @"hmd";
static NSString * const kFeatureLiveness       = @"liveness";
static NSString * const kFeatureQuality        = @"quality";
static NSString * const kFeatureVerification   = @"verification";

@interface FSPLicenseManager : NSObject

@property (nonatomic, readonly) NSString * license;
@property (nonatomic, readonly) NSDictionary * extensions;
@property (nonatomic, readonly) NSString * organization;

- (id) initWithContent:(NSString*)license;
- (id) initWithPath:(NSString *)path;

- (bool) hasExpired;
- (bool) isVerified;
- (bool) supportsFeatureWithName:(NSString*)feature;

@end

#endif
