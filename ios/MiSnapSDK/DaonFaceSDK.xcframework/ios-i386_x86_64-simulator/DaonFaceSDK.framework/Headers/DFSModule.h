//
//  DFSModule.h
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 7/25/19.
//  Copyright © 2019 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
NS_ASSUME_NONNULL_BEGIN

@interface DFSModule : NSObject

+ (BOOL) hasFrameWorkWithNames:(NSArray*)names;
+ (void *) openFrameworkWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
