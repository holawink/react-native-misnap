//
//  DFSAES
//
//  Created by Jonny Mortensen on 8/5/16.
//  Copyright © 2016 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFSCrypto : NSObject

+ (NSData*) secretKeyFromPassword:(NSString*)password salt:(NSData*)salt;
+ (NSMutableData *)randomDataOfLength:(size_t)length;

+ (NSData *) encrypt:(NSData*)data withKey:(NSData*)key;
+ (NSData *) decrypt:(NSData*)data withKey:(NSData*)key;

@end
