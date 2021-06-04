//
//  DFSKeychain
//  DaonFaceSDK
//
//  Created by Jonny Mortensen on 8/19/16.
//  Copyright © 2016 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFSKeychain : NSObject

+ (BOOL) writeKey:(NSData*)key withName:(NSString*)name;
+ (NSData*) readKeyWithName:(NSString*)name;

@end
