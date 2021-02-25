//
//  MiSnapSDKOverlayViewUX2.h
//  MiSnap
//
//  Created by Greg Fisch on 3/11/15.
//  Copyright (c) 2015 mitek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiSnapSDKOverlayView.h"

@interface MiSnapSDKOverlayViewUX2 : MiSnapSDKOverlayView

@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIImageView *successImageView;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet UILabel *torchLabel;
@property (weak, nonatomic) IBOutlet UIImageView *snapAnimationView;
@property (weak, nonatomic) IBOutlet UIImageView *ghostImageView;
@property (weak, nonatomic) IBOutlet UILabel *ghostTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topBarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarImageView;
@property (weak, nonatomic) IBOutlet UIView   *objectRectangleView;
@property (weak, nonatomic) IBOutlet UIImageView *guideDotImageView;

- (void)initializeObjects;
- (void)setupViewWithParams:(NSDictionary *)params;
- (void)setGhostImage:(NSString*)documentType withOrientation:(UIInterfaceOrientation)orientation;
- (void)setTorchButtonStatus:(BOOL)onFlag;
- (void)manageTorchButton:(BOOL)hasTorch;
- (void)updateGaugeValue:(int)fillPercentage;
- (void)showHint:(NSString *)hintString;
- (void)hideHint;
- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect;
- (void)hideSmartHint;

- (void)drawBoxAndBounce:(CGRect)documentRectangle;
- (void)runSnapAnimation;

@end
