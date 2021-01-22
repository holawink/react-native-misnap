//
//  MiSnapSDKViewControllerUX2.m
//  MiSnap
//
//  Created by Greg Fisch on 3/11/15.
//  Copyright (c) 2015 mitek. All rights reserved.
//

#import "MiSnapSDKViewControllerUX2.h"
#import "MiSnapSDKOverlayViewUX2.h"
#import "MiSnapSDKTutorialViewController.h"

@interface MiSnapSDKViewControllerUX2 () <MiSnapCaptureViewDelegate>

@property (nonatomic, strong) IBOutlet MiSnapSDKCaptureView* captureView;
@property (nonatomic, strong) IBOutlet MiSnapSDKOverlayViewUX2* overlayView;

@property (nonatomic, strong) NSMutableDictionary* captureParams;

@end

@implementation MiSnapSDKViewControllerUX2

#pragma mark - View Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - MiSnapCaptureViewDelegate methods

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView completionScoreUpdated:(int)completionScore withDocumentRect:(CGRect)documentRect
{
    __weak MiSnapSDKViewControllerUX2* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.captureParams[@"ShowDebugRectangle"] boolValue] == YES)
        {
            NSArray* cornerPoints = [wself.captureView getDocumentCornerPoints];
            [wself.overlayView drawDebugRectangle:cornerPoints];
        }
    });
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString
{
    __weak MiSnapSDKViewControllerUX2* wself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([hintString isEqualToString:kMiSnapHintTooDim])
        {
            [wself.overlayView showHint:kMiSnapHintTooDim];
        }
        else if ([hintString isEqualToString:kMiSnapHintTooBright])
        {
            [wself.overlayView showHint:kMiSnapHintTooBright];
        }
        else if ([hintString isEqualToString:kMiSnapHintNotSharp])
        {
            [wself.overlayView showHint:kMiSnapHintNotSharp];
        }
        else if ([hintString isEqualToString:kMiSnapHintRotation])
        {
            [wself.overlayView showHint:kMiSnapHintRotation];
        }
        else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
        {
            [wself.overlayView showHint:kMiSnapHintAngleTooLarge];
        }
        else if ([hintString isEqualToString:kMiSnapHintTooClose])
        {
            [wself.overlayView showHint:kMiSnapHintTooClose];
        }
        else if ([hintString isEqualToString:kMiSnapHintTooFar])
        {
            [wself.overlayView showHint:kMiSnapHintTooFar];
        }
        else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
        {
            [wself.overlayView showHint:kMiSnapHintNothingDetected];
        }
    });
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass([self class]);
}

+ (MiSnapSDKViewControllerUX2 *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"MiSnapUX2" bundle:nil] instantiateViewControllerWithIdentifier:[MiSnapSDKViewControllerUX2 storyboardIdentifier]];
}

@end
