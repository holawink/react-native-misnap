
#import "RNMisnap.h"
#import <RNMisnap/RNMisnap.h>
#import <MiSnapSDK/MiSnapSDK.h>
#import "MiSnapSDKViewControllerUX2.h"
#import "MiSnapSDKViewController.h"
#import "LivenessViewController.h"
#import <MiSnapLiveness/MiSnapLiveness.h>

@interface RNMisnap () <LivenessViewControllerDelegate>

// MiSnap
@property (nonatomic, strong) MiSnapSDKViewController *miSnapController;
@property (nonatomic, strong) NSString *selectedJobType;
@property (strong, nonatomic) MiSnapLivenessCaptureParameters *captureParams;

// Liveness
@property (nonatomic, strong) LivenessViewController *livenessController;

@end

@implementation RNMisnap

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(greet, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSString *greetText = @"HELLO FROM IOS NATIVE CODE";
    resolve(greetText);
    // reject([NSError errorWithDomain:@"com.companyname.app" code:0 userInfo:@{ @"text": @"something happend" }]);
}

RCT_EXPORT_METHOD(capture:(NSDictionary *)config resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    cResolver = resolve;
    cRejecter = reject;
    
    // Bypassing the tutorial views for iDFront an iDBack, as they dirupt the camera view making it black screen.

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MiSnapShowTutorialIdFront"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MiSnapShowTutorialIdBack"];

    self.miSnapController = nil;
    self.livenessController = nil;

    if ([config[@"captureType"] isEqualToString:@"idFront"]) {
        self.selectedJobType = kMiSnapDocumentTypeIdCardFront;
    } else if ([config[@"captureType"] isEqualToString:@"idBack"]) {
        self.selectedJobType = kMiSnapDocumentTypeIdCardBack;
    } else if ([config[@"captureType"] isEqualToString:@"face"]) {
        [self showLivenessPhotocamara:config];
        return;
    } else if ([config[@"captureType"] isEqualToString:@"creditCard"]) {
        self.selectedJobType = kMiSnapDocumentTypeCreditCard;
    }

    self.miSnapController = (MiSnapSDKViewController *)[[UIStoryboard storyboardWithName:@"MiSnapUX2" bundle:nil] instantiateViewControllerWithIdentifier:@"MiSnapSDKViewControllerUX2"];

    self.miSnapController.delegate = self;
    [self.miSnapController setupMiSnapWithParams:[self getMiSnapParameters:config]];
    self.miSnapController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    if (self.miSnapController != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                [rootViewController presentViewController:self.miSnapController animated:YES completion:nil ];
            }
        });
    } else {
        //reject(@"400", @"Could not create a misnap controller.", [NSError errorWithDomain:@"com.omni.minsnap" code:0 userInfo:@{ @"text": @"MiSnapSDKViewController controller not created." }]);
    }
}

- (void)showLivenessPhotocamara:(NSDictionary *)config
{
    self.captureParams = [[MiSnapLivenessCaptureParameters alloc] init];
    self.captureParams.timeout = 60;
    self.livenessController = [LivenessViewController instantiateFromStoryboard];
    self.livenessController.licenseKey = config[@"livenessLicenseKey"];
    self.livenessController.delegate = self;
    self.livenessController.captureParams = self.captureParams;
    self.livenessController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    if (self.livenessController != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
            if (rootViewController != nil) {
                [rootViewController presentViewController:self.livenessController animated:YES completion:nil];
            }
        });
    } else {
        //reject(@"400", @"Could not create a misnap controller.", [NSError errorWithDomain:@"com.omni.minsnap" code:0 userInfo:@{ @"text": @"MiSnapSDKViewController controller not created." }]);
    }
}

#pragma mark - <MiSnapViewControllerDelegate>

// Called when an image has been captured in either automatic or manual mode
- (void)miSnapFinishedReturningEncodedImage:(NSString *)encodedImage originalImage:(UIImage *)originalImage andResults:(NSDictionary *)results
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (rootViewController != nil) {
        [rootViewController dismissViewControllerAnimated:YES completion: ^{
            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
            resultDic[@"base64encodedImage"] = encodedImage;
            resultDic[@"metadata"] = results;
            cResolver(resultDic);
        }];
    }
}

- (NSDictionary *)getMiSnapParameters:(NSDictionary *)options
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForACH]];

    // Must set specific server type and server version
    [parameters setObject:@"test" forKey:kMiSnapServerType];
    [parameters setObject:@"0.0" forKey:kMiSnapServerVersion];

    // LanguageOverride forces only English "en". Uncomment this to enforce just English localization.
    [parameters setObject:@"es" forKey:@"LanguageOverride"];
    [parameters setObject:@"90000" forKey:kMiSnapTimeout];
    [parameters setObject:@"2" forKey:kMiSnapMaxCaptures]; // Shows how to set 3 rather than default 5

    if ([self.selectedJobType isEqualToString:kMiSnapDocumentTypeIdCardFront]) { //@"ID_CARD_FRONT"
        parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForIdCardFront]];
        [parameters setObject:@"ID Card Front" forKey:kMiSnapShortDescription];
        [parameters setObject:@"0" forKey:kMiSnapTorchMode];
    } else if ([self.selectedJobType isEqualToString:kMiSnapDocumentTypeIdCardBack]) { //@"ID_CARD_FRONT"
        parameters = [NSMutableDictionary dictionaryWithDictionary:[MiSnapSDKViewController defaultParametersForIdCardBack]];
        [parameters setObject:@"ID Card Back" forKey:kMiSnapShortDescription];
        [parameters setObject:@"0" forKey:kMiSnapTorchMode];
    }

    if (options[@"autocapture"] == NO) {
        [parameters setObject:@"1" forKey:kMiSnapCaptureMode];
    }

    return [parameters copy];
}

#pragma mark - <LivenessViewControllerDelegate>

- (void)livenessCaptureSuccess:(MiSnapLivenessCaptureResults *)results
{
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    resultDic[@"base64encodedImage"] = results.encodedImage;
    resultDic[@"metadata"] = @{ @"data": results.uxpData };
    cResolver(resultDic);

    if (results.isSpoofDetected) {
        // Handle spoof detected during successful capture
        //NSLog(@"*** Spoof detected");
    } else {
        // Handle successful capture
        //NSLog(@"*** Successs");
    }
    //NSLog(@"Success results: %@", results.uxpData);
}

@end
