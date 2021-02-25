//
//  NSString+Liveness.m
//  SampleApp
//
//  Created by Stas Tsuprenko on 2/26/18.
//  Copyright © 2018 Mitek Systems. All rights reserved.
//

#import "NSString+Liveness.h"

@implementation NSString (Liveness)

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [[NSBundle mainBundle] localizedStringForKey:key value:key table:@"FacialCaptureLocalizable"];
}

@end
