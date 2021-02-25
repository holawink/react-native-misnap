//
//  LivenessHelpAutoViewController.h
//  SampleApp
//
//  Created by Jeremy Jessup on 4/11/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LivenessHelpAutoViewControllerDelegate <NSObject>

- (void)tutorialCancelButtonPressed;

@end

@interface LivenessHelpAutoViewController : UIViewController

@property (nonatomic) id <LivenessHelpAutoViewControllerDelegate> delegate;

+ (LivenessHelpAutoViewController *)instantiateFromStoryboard;

@end
