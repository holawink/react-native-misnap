//
//  MiSnapSDKOverlayView.m
//  MiSnapDevApp
//
//  Created by Steve Blake on 12/1/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import "MiSnapSDKOverlayView.h"
#import <MiSnapSDK/MiSnapSDK.h>

@interface MiSnapSDKOverlayView ()

@property (nonatomic, strong) MiSnapSDKParameters* docCaptureParams;
@property (nonatomic, strong) NSArray* cornersArray;

@end

@implementation MiSnapSDKOverlayView

- (UIImage *)getResourcePNG:(NSString *)filename
{
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* pathname = [bundle pathForResource:filename ofType:@"png"];
    UIImage* image = [UIImage imageNamed:pathname];
    
    // Fix for iPhone 4 bug when it can't find the image
    if (image == nil)
        image = [UIImage imageNamed:filename];
    
    return image;
}

- (void)scaleGhostImageWithOrientation:(UIInterfaceOrientation)orientation withOrientationMode:(MiSnapOrientationMode)orientationMode
{
    self.ghostImageView.alpha = 0.0;
    self.ghostTextLabel.alpha = 0.0;
    
    CGFloat imageAspectRatio = self.ghostImageView.image.size.width > self.ghostImageView.image.size.height ? self.ghostImageView.image.size.width / self.ghostImageView.image.size.height : self.ghostImageView.image.size.height / self.ghostImageView.image.size.width;
    
    CGFloat ghostImageWidth = 0;
    CGFloat ghostImageHeight = 0;
    CGPoint ghostImageCenter = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    
    CGSize bounds = [UIScreen mainScreen].bounds.size;
    CGFloat width = bounds.width;
    CGFloat height = bounds.height;
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            if (width < height)
            {
                width = bounds.height;
                height = bounds.width;
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && width / height > 1.8)
            {
                width = height * 16/9;
                ghostImageCenter = CGPointMake(width * 0.5, height * 0.5);
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && width / height < 1.4)
            {
                height = width * 9/16;
            }
            
            ghostImageWidth = width * self.docCaptureParams.minLandscapeHorizontalFill / 1000.0;
            if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
                [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
                [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
            {
                ghostImageWidth *= 1.34f; // The guide is bigger to allow more flexibility in device distance from doc
            }
            
            if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
            {
                ghostImageWidth *= 1.15f; // The guide is bigger to allow more flexibility in device distance from doc
            }

            ghostImageHeight = ghostImageWidth / imageAspectRatio;
            break;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationUnknown:
            if (width > height)
            {
                width = bounds.height;
                height = bounds.width;
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && height / width > 1.8)
            {
                height = width * 16/9;
                ghostImageCenter = CGPointMake(width * 0.5, height * 0.5);
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && height / width < 1.4)
            {
                width = height * 9/16;
            }
            
            if (orientationMode == MiSnapOrientationModeDevicePortraitGhostPortrait)
            {
                ghostImageHeight = height * self.docCaptureParams.minLandscapeHorizontalFill / 1000.0;
                if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
                    [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
                    [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
                {
                    ghostImageHeight *= 1.34f; // The guide is bigger to allow more flexibility in device distance from doc
                }

                if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
                {
                    ghostImageHeight *= 1.15f; // The guide is bigger to allow more flexibility in device distance from doc
                }

                ghostImageWidth = ghostImageHeight / imageAspectRatio;
            }
            else if (orientationMode == MiSnapOrientationModeDevicePortraitGhostLandscape)
            {
                ghostImageWidth = width * self.docCaptureParams.minPortraitHorizontalFill / 1000.0;
                ghostImageWidth *= 1.14f; // The guide is bigger to allow more flexibility in device distance from doc
                ghostImageHeight = ghostImageWidth / imageAspectRatio;
            }
            break;
    }
    
    self.ghostImageView.frame = CGRectMake(0, 0, ghostImageWidth, ghostImageHeight);
    self.ghostImageView.center = ghostImageCenter;
//    NSLog(@"MSOV scaleGhost set frame %@", NSStringFromCGRect(self.ghostImageView.frame));
//    if (self.ghostImageView.frame.origin.x < 0) {
//        NSLog(@"MSOV scaleGhost set frame x < 0 %@", NSStringFromCGRect(self.ghostImageView.frame));
//        ;
//    }
    CGFloat ghostTextWidth = 0;
    CGFloat ghostTextHeight = 0;
    
    /* Scale ghost text for document type */
    
    if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeCheckFront] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeCheckBack] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeACH])
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.7;
            ghostTextHeight = ghostImageHeight * 0.4;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.7;
                ghostTextHeight = ghostImageHeight * 0.4;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
             [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
             [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.85;
            ghostTextHeight = ghostImageHeight * 0.3;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.9;
                ghostTextHeight = ghostImageHeight * 0.27;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.85;
            ghostTextHeight = ghostImageHeight * 0.3;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.9;
                ghostTextHeight = ghostImageHeight * 0.27;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeLandscapeDoc])
    {
        //        self.ghostImageView.image = nil; // We used an image to get a width and height, but don't want to show it
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.75;
            ghostTextHeight = ghostImageHeight * 0.3;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.8;
                ghostTextHeight = ghostImageHeight * 0.27;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.75;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeBalanceTransfer] ||
             [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeRemittance])
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.85;
            ghostTextHeight = ghostImageHeight * 0.3;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeW2])
    {
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            ghostTextWidth = ghostImageWidth * 0.85;
            ghostTextHeight = ghostImageHeight * 0.3;
            self.ghostTextLabel.numberOfLines = 6;
        }
        else
        {
            if (self.orientationMode != MiSnapOrientationModeDeviceLandscapeGhostLandscape)
            {
                ghostTextWidth = ghostImageWidth * 0.9;
                ghostTextHeight = ghostImageHeight * 0.27;
                self.ghostTextLabel.numberOfLines = 6;
            }
            else
            {
                ghostTextWidth = ghostImageWidth * 0.85;
                ghostTextHeight = ghostImageHeight * 0.3;
                self.ghostTextLabel.numberOfLines = 6;
            }
        }
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeVIN])
    {
        // Keep doc type but don't implement any ghost
    }
    
    self.ghostTextLabel.frame = CGRectMake(0, 0, ghostTextWidth, ghostTextHeight);
    self.ghostTextLabel.center = ghostImageCenter;
    
    [self resizeFont];
    
    NSTimeInterval delayTime = self.aspectRatio < 1.76 ? 0.4 : 0.3;
    
    CGFloat ghostImageAlpha = [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeLandscapeDoc] ? 0.0 : 1.0;
    
    [UIView animateWithDuration:0.25
                          delay:delayTime
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.ghostImageView.alpha = ghostImageAlpha;
                         self.ghostTextLabel.alpha = 0.7;
                     }
                     completion:nil
     ];
}

- (void)resizeFont
{
    if (self.ghostTextLabel.frame.size.width == 0 || self.ghostTextLabel.frame.size.height == 0)
    {
        return;
    }
    
    CGFloat fontSize = 70;
    
    while (true)
    {
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
        UIFont *currentFont = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
        
        CGRect ghostTextRect = [self.ghostTextLabel.text boundingRectWithSize:CGSizeMake(self.ghostTextLabel.frame.size.width, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName : currentFont}
                                                                      context:nil
                                ];
        
        //NSLog(@"Text rect: %.fx%.f for font size: %.f", ghostTextRect.size.width, ghostTextRect.size.height, fontSize);
        //NSLog(@"Ghost rect: %.fx%.f", self.ghostTextLabel.frame.size.width, self.ghostTextLabel.frame.size.height);
        
        if (ghostTextRect.size.height > self.ghostTextLabel.frame.size.height)
        {
            fontSize -= 1;
        }
        else
        {
            self.ghostTextLabel.font = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
            break;
        }
    }
}

- (void)resizeJobTitleLabelFont
{
    if (self.jobTitleLabel.frame.size.width == 0 || self.jobTitleLabel.frame.size.height == 0)
    {
        return;
    }
    
    CGFloat fontSize = 22;
    
    while (true)
    {
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
        UIFont *currentFont = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
        
        CGRect jobTitleTextRect = [self.jobTitleLabel.text boundingRectWithSize:CGSizeMake(self.jobTitleLabel.frame.size.width, CGFLOAT_MAX)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName : currentFont}
                                                                        context:nil
                                   ];
        
        //NSLog(@"Text rect: %.fx%.f for font size: %.f", ghostTextRect.size.width, ghostTextRect.size.height, fontSize);
        //NSLog(@"Ghost rect: %.fx%.f", self.ghostTextLabel.frame.size.width, self.ghostTextLabel.frame.size.height);
        
        if (jobTitleTextRect.size.height > self.jobTitleLabel.frame.size.height)
        {
            fontSize -= 1;
        }
        else
        {
            self.jobTitleLabel.font = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
            break;
        }
    }
}

- (void)setGhostImage:(NSString*)documentType withOrientation:(UIInterfaceOrientation)orientation
{
    [self resizeJobTitleLabelFont];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation))
    {
        self.jobTitleLabel.textColor = [UIColor blackColor];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(orientation))
    {
        self.jobTitleLabel.textColor = [UIColor whiteColor];
    }
    
    self.ghostImageView.image = nil;
    
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];
    
    NSString *ghostTxtString;
    
    if ((self.docCaptureParams.captureMode == MiSnapCaptureModeManual)
        || (self.docCaptureParams.captureMode == MiSnapCaptureModeManualAssist)
        || (self.docCaptureParams.captureMode == MiSnapCaptureModeHighResManual))
    {
        if ([documentType isEqualToString:kMiSnapDocumentTypeACH])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_front" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check_manual"];
        }
        //        else if ([documentType hasPrefix:kMiSnapDocumentTypeAutoInsurancePrefix])
        //        {
        //            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"manual_ghost_auto_insurance_card"];
        //            ghostTxtString = @"";
        //        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeBalanceTransfer])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_balance_remittance" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_remittance_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeCheckBack])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_back" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeCheckFront])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_front" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check_manual"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeDriverLicense])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_drivers_license_manual"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeIdCardFront])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_id_card_manual"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeIdCardBack])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_id_card_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeLandscapeDoc])
        {
            // Use passport as the ghost image to let the ghost text get sized.  Set image alpha to 0 to hide it
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_passport" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_document_landscape_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeRemittance])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_balance_remittance" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_remittance_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeVIN])   // MiSnap can only capture a VIN manually - No borders
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"manual_ghost_vin" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_vin_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeW2])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_w2" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_w2_manual"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypePassport])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_passport" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_passport_manual"];
        }
        else
        {
            self.ghostImageView.image = nil;
            ghostTxtString = @"";
        }
    }
    else
    {
        if ([documentType isEqualToString:kMiSnapDocumentTypeACH])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_front" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check"];
        }
        //        else if ([documentType hasPrefix:kMiSnapDocumentTypeAutoInsurancePrefix])
        //        {
        //            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_auto_insurance_card"];
        //            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_insurance_card"];
        //        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeBalanceTransfer])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_balance_remittance" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_remittance"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeCheckBack])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_back" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeCheckFront])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_check_front" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_check"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeDriverLicense])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_drivers_license"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeIdCardFront])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_id_card"];
        }
        else if ([documentType hasPrefix:kMiSnapDocumentTypeIdCardBack])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_id_card" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_id_card"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeLandscapeDoc])
        {
            // Use passport as the ghost image to let the ghost text get sized.  Set image alpha to 0 to hide it
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_passport" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_document_landscape"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeRemittance])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_balance_remittance" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_remittance"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypeW2])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_w2" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_w2"];
        }
        else if ([documentType isEqualToString:kMiSnapDocumentTypePassport])
        {
            self.ghostImageView.image = [resourceLocator getLocalizedImage:@"ghost_passport" withOrientation:orientation withOrientationMode:self.orientationMode];
            ghostTxtString = [resourceLocator getLocalizedString:@"ghost_image_passport"];
        }
        else
        {
            self.ghostImageView.image = nil;
            ghostTxtString = @"";
        }
    }
    
    self.ghostImageView.accessibilityLabel = ghostTxtString;
    
    // Ghost text not needed for these document types
    if ([documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        // These ghost images now have graphics to show how to center the document
        // The accessibilityLabel is set, so effectively hide the ghostTxtString from the view
        ghostTxtString = @"";
    }
    
    self.ghostTextLabel.attributedText = [[NSAttributedString alloc] initWithString:ghostTxtString
                                                                         attributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithInt:-2],
                                                                                      NSStrokeColorAttributeName: [UIColor whiteColor],
                                                                                      NSForegroundColorAttributeName: [UIColor blackColor]}
                                          ];
    self.ghostTextLabel.alpha = 0.7;
    
    // Do not scale a nil image
    if (self.ghostImageView.image != nil) {
        // There is a valid image to scale
        __weak MiSnapSDKOverlayView* wself = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself scaleGhostImageWithOrientation:orientation withOrientationMode:self.orientationMode];
            wself.ghostImageView.hidden = NO;
            wself.ghostTextLabel.hidden = NO;
        });
    }
}

- (void)setGhostImageAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.5 animations:^{
        self.ghostImageView.alpha = alpha;
    }];
}

- (void)showGhostImage
{
    [self setGhostImageAlpha:1.0];
}

- (void)hideGhostImage
{
    [self setGhostImageAlpha:0.0];
    [self.ghostTextLabel removeFromSuperview];
}

- (void)setupJobTitle
{
    NSString* jobTitle = nil;
    MiSnapSDKResourceLocator* resourceLocator = [MiSnapSDKResourceLocator initWithLanguageKey:self.docCaptureParams.languageOverride];
    
    if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeCheckFront])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_check_front_text"];
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeCheckBack])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_check_back_text"];
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_license_text"];
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_id_card_text"];
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_id_card_text"];
    }
    else if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_passport_text"];
    }
    else
    {
        jobTitle = [resourceLocator getLocalizedString:@"misnap_document_text"];
    }
    
    self.jobTitleLabel.text = [resourceLocator getLocalizedString:jobTitle];
    self.jobTitleLabel.accessibilityLabel = [resourceLocator getLocalizedString:jobTitle];
}

- (void)manageTorchButton:(BOOL)hasTorch
{
    if ([self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeDriverLicense] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardFront] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypeIdCardBack] ||
        [self.docCaptureParams.documentType isEqualToString:kMiSnapDocumentTypePassport])
    {
        return;
    }

    self.torchButton.hidden = !hasTorch;
}

- (void)showManualCaptureButton
{
    self.snapButton.hidden = NO;
    self.snapButton.enabled = YES;
}

- (void)drawDebugRectangle:(NSArray *)cornerPoints
{
    if (cornerPoints != nil)
    {
        self.cornersArray = [NSArray arrayWithArray:cornerPoints];
        [self setNeedsDisplay];
    }
}

- (void)drawText:(NSString *)text atPoint:(CGPoint)point withSize:(CGSize)size
{
    CGRect textRect = CGRectMake((point.x - size.width / 2), (point.y - size.height / 2), size.width, size.height);
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *fontAttributes = @{
                                     NSFontAttributeName                : [UIFont fontWithName:@"Avenir" size:15],
                                     NSForegroundColorAttributeName     : [UIColor blackColor],
                                     NSParagraphStyleAttributeName      : textStyle
                                     };
    
    [text drawInRect:textRect withAttributes:fontAttributes];
}

- (void)updateSnapButtonRelativeCenterX:(CGFloat)relativeX relativeCenterY:(CGFloat)relativeY relativeSize:(CGFloat)relativeSize
{
    for (NSLayoutConstraint *constraint in self.snapButton.constraints)
    {
        [self.snapButton removeConstraint:constraint];
    }
    
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstItem == self.snapButton || constraint.secondItem == self.snapButton)
        {
            [self removeConstraint:constraint];
        }
    }
    
    NSLayoutConstraint *x = [NSLayoutConstraint constraintWithItem:self.snapButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:relativeX / 0.5
                                                          constant:0
                             ];
    
    NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:self.snapButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:relativeY / 0.5
                                                          constant:0
                             ];
    
    NSLayoutConstraint *width;
    NSLayoutConstraint *height;
    CGFloat size;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        size = self.frame.size.height * relativeSize;
    }
    else
    {
        size = self.frame.size.width * relativeSize;
    }
    
    width = [NSLayoutConstraint constraintWithItem:self.snapButton
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:size
             ];

    height = [NSLayoutConstraint constraintWithItem:self.snapButton
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:nil
                                          attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1
                                           constant:size
              ];
    
    [NSLayoutConstraint activateConstraints:@[x, y, width, height]];
    
    [self setNeedsUpdateConstraints];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat diameter = 20;
    
    bool showDebugRectangleFlag = [self.docCaptureParams.paramsDictionary[@"ShowDebugRectangle"] boolValue];
    
    //    showDebugRectangleFlag = YES;
    if ((_cornersArray != nil) && (showDebugRectangleFlag == TRUE))
    {
        NSValue* val0 = [_cornersArray objectAtIndex:0];
        NSValue* val1 = [_cornersArray objectAtIndex:1];
        NSValue* val2 = [_cornersArray objectAtIndex:2];
        NSValue* val3 = [_cornersArray objectAtIndex:3];
        
        CGPoint p0 = [val0 CGPointValue];
        CGPoint p1 = [val1 CGPointValue];
        CGPoint p2 = [val2 CGPointValue];
        CGPoint p3 = [val3 CGPointValue];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Draw red rectangle
        [[UIColor redColor] setStroke];
        
        CGContextSetLineWidth(context, 3.0);
        CGContextSetAlpha(context, 1.0);
        
        CGContextBeginPath(context);
        
        CGContextMoveToPoint(context, p0.x, p0.y);
        CGContextAddLineToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextAddLineToPoint(context, p3.x, p3.y);
        CGContextAddLineToPoint(context, p0.x, p0.y);
        
        CGContextStrokePath(context);
        
        [[UIColor greenColor] setFill];
        
        CGContextAddEllipseInRect(context, CGRectMake((p0.x - diameter / 2), (p0.y - diameter / 2), diameter, diameter));
        CGContextFillPath(context);
        [self drawText:@"A" atPoint:p0 withSize:CGSizeMake(diameter, diameter)];
        
        CGContextAddEllipseInRect(context, CGRectMake((p1.x - diameter / 2), (p1.y - diameter / 2), diameter, diameter));
        CGContextFillPath(context);
        [self drawText:@"B" atPoint:p1 withSize:CGSizeMake(diameter, diameter)];
        
        CGContextAddEllipseInRect(context, CGRectMake((p2.x - diameter / 2), (p2.y - diameter / 2), diameter, diameter));
        CGContextFillPath(context);
        [self drawText:@"C" atPoint:p2 withSize:CGSizeMake(diameter, diameter)];
        
        CGContextAddEllipseInRect(context, CGRectMake((p3.x - diameter / 2), (p3.y - diameter / 2), diameter, diameter));
        CGContextFillPath(context);
        [self drawText:@"D" atPoint:p3 withSize:CGSizeMake(diameter, diameter)];
    }
}

- (void)initializeObjects {}
- (void)setupViewWithParams:(NSDictionary *)params {}
- (void)setTorchButtonStatus:(BOOL)onFlag {}
- (void)openGaugeImageView {}
- (void)closeGaugeImageView {}
- (void)updateGaugeValue:(int)fillPercentage {}
- (void)showSmartHint:(NSString *)hintString withBoundingRect:(CGRect)boundingRect {}
- (void)hideSmartHint {}
- (void)hideHint {}
- (void)drawBoxAndBounce:(CGRect)documentRectangle {}
- (void)runSnapAnimation {}
- (void)hideAllUIElements {}
- (void)hideUIElementsOnSuccessfulCapture {}
- (void)updateSnapButtonLocation {}

@end
