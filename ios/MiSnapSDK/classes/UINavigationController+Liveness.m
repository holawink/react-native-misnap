//
//  UINavigationController+Liveness.m
//  SampleApp
//
//  Created by Stas Tsuprenko on 2/22/18.
//  Copyright © 2018 Mitek Systems. All rights reserved.
//

#import "UINavigationController+Liveness.h"

@implementation UINavigationController (Liveness)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

@end
