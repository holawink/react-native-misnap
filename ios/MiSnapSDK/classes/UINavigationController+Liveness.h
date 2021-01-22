//
//  UINavigationController+Liveness.h
//  SampleApp
//
//  Created by Stas Tsuprenko on 2/22/18.
//  Copyright © 2018 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Liveness)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

- (BOOL)shouldAutorotate;

@end
