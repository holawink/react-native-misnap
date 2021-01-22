//
//  NSString+Liveness.h
//  SampleApp
//
//  Created by Stas Tsuprenko on 2/26/18.
//  Copyright © 2018 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Liveness)

/**
 Returns the localized string from the FacialCaptureLocalizable string table.
 If the key is not found, it's returned as the default value.
 
 @param key The lookup key associated with a translated value
 @return The localized string value
 @see FacialCaptureLocalizable.strings
 */
+ (NSString *)localizedStringForKey:(NSString *)key;

@end
