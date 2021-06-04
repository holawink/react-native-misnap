//
//  ModuleProtocol.h
//  DaonFaceSDK
//
//  Created by Neil Johnston on 12/10/15.
//  Copyright © 2015 Daon. All rights reserved.
//

#ifndef Module_h
#define Module_h

#import <UIKit/UIKit.h>
#import <DaonFaceSDK/FSPLicenseManager.h>

@protocol DFSModuleProtocol <NSObject>

- (NSString*) name;
- (void) stop;

@optional

- (void) didChangeConfiguration:(NSDictionary*)configuration;
- (void) didChangeImageSize:(CGSize)size;
- (void) didReset;

@end

#endif /* Module_h */
