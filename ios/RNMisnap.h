
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <UIKit/UIKit.h>
#import <MiSnapSDK/MiSnapSDK.h>
#import "MiSnapSDKViewController.h"

@interface RNMisnap : NSObject <RCTBridgeModule, MiSnapViewControllerDelegate> {
    RCTPromiseResolveBlock  cResolver;
    RCTPromiseRejectBlock   cRejecter;
}

// Configuration properties.
@property (nonatomic, strong) NSDictionary *config;

// Current capture position.
@property (nonatomic, assign) int currentPosition;
@property (nonatomic, strong) UIImage *miSnapImage;

@end
  
