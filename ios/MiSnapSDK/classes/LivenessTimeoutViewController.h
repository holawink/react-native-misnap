//
//  LivenessTimeoutViewController.h
//  SampleApp
//
//  Created by Jeremy Jessup on 5/13/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LivenessTimeoutViewControllerDelegate <NSObject>

- (void)retryAuto:(BOOL)retry;
- (void)tutorialCancelButtonPressed;

@end

@interface LivenessTimeoutViewController : UIViewController

+ (LivenessTimeoutViewController *)instantiateFromStoryboard;

@property (nonatomic) id <LivenessTimeoutViewControllerDelegate> delegate;

@end
