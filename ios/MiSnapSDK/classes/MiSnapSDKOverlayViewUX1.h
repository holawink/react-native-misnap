//
//  MiSnapSDKOverlayViewUX1.h
//
//  Created by Steve Blake on 11/22/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiSnapSDKOverlayView.h"

@interface MiSnapSDKOverlayViewUX1 : MiSnapSDKOverlayView

@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UIView   *objectRectangleView;
@property (weak, nonatomic) IBOutlet UIImageView *snapAnimationView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ghostImageView;
@property (weak, nonatomic) IBOutlet UILabel *ghostTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gaugeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *guideDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smartBubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *smartBubbleLabel;

- (void)initializeObjects;
- (void)setupViewWithParams:(NSDictionary *)params;
- (void)setTorchButtonStatus:(BOOL)onFlag;
- (void)openGaugeImageView;
- (void)closeGaugeImageView;
- (void)updateGaugeValue:(int)fillPercentage;
- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect;
- (void)hideSmartHint;
- (void)hideHint;
- (void)drawBoxAndBounce:(CGRect)documentRectangle;
- (void)runSnapAnimation;

@end
