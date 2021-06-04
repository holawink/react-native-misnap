//
//  LivenessViewController.h
//  SampleApp
//
//  Created by Jeremy Jessup on 4/7/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapLiveness/MiSnapLiveness.h>

@protocol LivenessViewControllerDelegate <NSObject>

@required
- (void)livenessCaptureSuccess:(MiSnapLivenessCaptureResults*)results;

@optional
- (void)livenessCancelled;

- (void)livenessDidFinishSuccessAnimation;

@end

@interface LivenessViewController : UIViewController

@property (nonatomic) id <LivenessViewControllerDelegate> delegate;

@property (strong, nonatomic) MiSnapLivenessCaptureParameters *captureParams;

@property (nonatomic) BOOL shouldAutoDissmiss;

@property (nonatomic) NSString *licenseKey;

+ (LivenessViewController *)instantiateFromStoryboard;

@end
