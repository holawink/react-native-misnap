//
//  MiSnapSDKViewControllerUX1.m
//  MiSnap
//
//  Created by Steve Blake on 11/30/2017.
//  Copyright (c) 2017 mitek. All rights reserved.
//

#import "MiSnapSDKViewControllerUX1.h"
#import "MiSnapSDKOverlayViewUX1.h"

@interface MiSnapSDKViewControllerUX1 () <MiSnapCaptureViewDelegate>

@property (nonatomic, strong) IBOutlet MiSnapSDKCaptureView* captureView;
@property (nonatomic, strong) IBOutlet MiSnapSDKOverlayViewUX1* overlayView;

@property (nonatomic, assign) BOOL gaugeIsShowing;

@end

@implementation MiSnapSDKViewControllerUX1

#pragma mark - MiSnapCaptureViewDelegate methods

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView completionScoreUpdated:(int)completionScore withDocumentRect:(CGRect)documentRect
{
    __weak MiSnapSDKViewControllerUX1* wself = self;
    
    //NSLog(@"MSVC completionScoreUpdated %d, gaugeIsShowing %d", completionScore, gaugeIsShowing);
    //NSLog(@"MSVC calculateCompletionScore results %@", [captureView getDocumentResults]);
    //NSLog(@"MSVC ghost frame %@", NSStringFromCGRect(self.overlayView.ghostImageView.frame));
    //if (self.overlayView.ghostImageView.frame.origin.x < 0) {
    //    NSLog(@"MSOV scaleGhost frame x < 0 %@", NSStringFromCGRect(self.overlayView.ghostImageView.frame));
    //}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // The gauge and ghost image both stay on to support new smart bubbles
        [wself.overlayView openGaugeImageView];
        [wself.overlayView showGhostImage];
        [wself.overlayView showGhostImage];
        self.gaugeIsShowing = TRUE;
        
        if (completionScore > 0)
        {
            
            if (self.gaugeIsShowing == FALSE)
            {
                self.gaugeIsShowing = TRUE;
            }
            else
            {
                [wself.overlayView updateGaugeValue:completionScore];
            }
        }
        
        NSArray* cornerPoints = [wself.captureView getDocumentCornerPoints];
        [wself.overlayView drawDebugRectangle:cornerPoints];
    });
}

- (void)miSnapCaptureView:(MiSnapSDKCaptureView *)captureView userHintAvailable:(NSString *)hintString
{
    //NSLog(@"MSVC : userHintAvailable %@", hintString);
    
    if (self.gaugeIsShowing)
    {
        __weak MiSnapSDKViewControllerUX1* wself = self;
        
        __block NSString *message = @"Not defined";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([hintString isEqualToString:kMiSnapHintTooDim])
            {
                message = kMiSnapHintTooDim;
            }
            else if ([hintString isEqualToString:kMiSnapHintTooBright])
            {
                message = kMiSnapHintTooBright;
            }
            else if ([hintString isEqualToString:kMiSnapHintNotSharp])
            {
                message = kMiSnapHintNotSharp;
            }
            else if ([hintString isEqualToString:kMiSnapHintRotation])
            {
                message = kMiSnapHintRotation;
            }
            else if ([hintString isEqualToString:kMiSnapHintAngleTooLarge])
            {
                message = kMiSnapHintAngleTooLarge;
            }
            else if ([hintString isEqualToString:kMiSnapHintTooClose])
            {
                message = kMiSnapHintTooClose;
            }
            else if ([hintString isEqualToString:kMiSnapHintTooFar])
            {
                message = kMiSnapHintTooFar;
            }
            else if ([hintString isEqualToString:kMiSnapHintNothingDetected])
            {
                message = kMiSnapHintNothingDetected;
            }
            
            [wself.overlayView showSmartHint:message withBoundingRect:CGRectZero];
        });
    }
}

+ (NSString *)storyboardIdentifier
{
    return NSStringFromClass([self class]);
}

+ (MiSnapSDKViewControllerUX1 *)instantiateFromStoryboard
{
    return [[UIStoryboard storyboardWithName:@"MiSnapUX1" bundle:nil] instantiateViewControllerWithIdentifier:[MiSnapSDKViewControllerUX1 storyboardIdentifier]];
}

@end
