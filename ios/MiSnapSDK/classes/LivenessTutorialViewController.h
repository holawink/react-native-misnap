//
//  LivenessTutorialViewController.h
//  SampleApp
//
//  Created by Jeremy Jessup on 4/26/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LivenessTutorialViewControllerDelegate <NSObject>

- (void)tutorialStartButtonPressed;
- (void)tutorialCancelButtonPressed;

@end

@interface LivenessTutorialViewController : UIViewController

@property (nonatomic) id <LivenessTutorialViewControllerDelegate> delegate;

+ (LivenessTutorialViewController *)instantiateFromStoryboard;

@end
