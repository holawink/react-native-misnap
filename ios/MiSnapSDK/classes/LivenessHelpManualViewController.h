//
//  LivenessHelpManualViewController.h
//  SampleApp
//
//  Created by Jeremy Jessup on 5/12/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LivenessHelpManualViewControllerDelegate <NSObject>

- (void)tutorialCancelButtonPressed;

@end

@interface LivenessHelpManualViewController : UIViewController

@property (nonatomic) id <LivenessHelpManualViewControllerDelegate> delegate;

+ (LivenessHelpManualViewController *)instantiateFromStoryboard;

@end
