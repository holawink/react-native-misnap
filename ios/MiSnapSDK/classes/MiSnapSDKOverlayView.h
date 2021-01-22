//
//  MiSnapSDKOverlayView.h
//  MiSnapDevApp
//
//  Created by Steve Blake on 12/1/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapSDK/MiSnapSDK.h>

@interface MiSnapSDKOverlayView : UIView

@property (nonatomic) BOOL showGlareTracking;  // Setting to show or hide glare box
@property (nonatomic, assign) MiSnapOrientationMode orientationMode;

@property (weak, nonatomic) IBOutlet UIImageView *ghostImageView;
@property (weak, nonatomic) IBOutlet UILabel *ghostTextLabel;
@property (nonatomic, assign) CGFloat aspectRatio;
@property (weak, nonatomic) IBOutlet UILabel *jobTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;

- (void)initializeObjects;
- (void)setupViewWithParams:(NSDictionary *)params;
- (void)setGhostImage:(NSString*)documentType withOrientation:(UIInterfaceOrientation)orientation;
- (void)scaleGhostImageWithOrientation:(UIInterfaceOrientation)orientation withOrientationMode:(MiSnapOrientationMode)orientationMode;
- (void)showGhostImage;
- (void)hideGhostImage;
- (void)setTorchButtonStatus:(BOOL)onFlag;
- (void)setupJobTitle;
- (void)openGaugeImageView;
- (void)closeGaugeImageView;
- (void)updateGaugeValue:(int)fillPercentage;
- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect;
- (void)hideSmartHint;
- (void)hideHint;
- (void)drawBoxAndBounce:(CGRect)documentRectangle;
- (void)runSnapAnimation;
- (void)hideAllUIElements;
- (void)hideUIElementsOnSuccessfulCapture;
- (void)showManualCaptureButton;
- (void)manageTorchButton:(BOOL)hasTorch;
- (void)drawDebugRectangle:(NSArray *)cornerPoints;
- (void)updateSnapButtonRelativeCenterX:(CGFloat)relativeX relativeCenterY:(CGFloat)relativeY relativeSize:(CGFloat)relativeSize;
- (void)updateSnapButtonLocation;

- (UIImage *)getResourcePNG:(NSString *)filename;

@end
