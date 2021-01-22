//
//  AutosizeLabel.m
//  SampleApp
//
//  Created by Stas Tsuprenko on 1/29/17.
//  Copyright © 2017 Mitek Systems. All rights reserved.
//

#import "AutosizeLabel.h"

@implementation AutosizeLabel

- (void)resizeFontSize:(NSString *)longestString
{
    CGFloat fontSize = [self getFontSizeToFitRectangle:longestString];
    self.font = [UIFont fontWithName:[self.font fontName] size:fontSize];
    [self drawTextInRect:self.frame];
}

- (CGFloat)getFontSizeToFitRectangle:(NSString *)text
{
    CGFloat maxFontSize = 100;
    CGFloat minFontSize = 5;
//    CGSize constraintSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    BOOL isPhone = [[UIDevice currentDevice].model caseInsensitiveCompare:@"iPhone"] == NSOrderedSame;
    CGFloat framePad = (isPhone) ? 15 : 0;
    CGFloat deviceFontSize = (isPhone) ? 0 : 0;
    deviceFontSize = [UIScreen mainScreen].bounds.size.width <= 320 ? 2 : 0;
    
    int q = (int) maxFontSize;
    int p = (int) minFontSize;
    int currentSize = 0;
    
    while (p <= q)
    {
        currentSize = (p + q) / 2;
        UIFont *font = [UIFont fontWithName:[self.font fontName] size:(CGFloat)currentSize];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : font}];
        CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                             context:nil];
        if (textRect.size.height < self.frame.size.height && textRect.size.height >= (self.frame.size.height - framePad) && textRect.size.width < self.frame.size.width && textRect.size.width >= (self.frame.size.width - framePad))
        {
            break;
        }
        else if (textRect.size.height > self.frame.size.height || textRect.size.width > self.frame.size.width)
        {
            q = currentSize - 1;
        }
        else
        {
            p = currentSize + 1;
        }
    }
    
    return (CGFloat)currentSize - deviceFontSize;
}

-(void)drawTextInRect:(CGRect)rect
{
    NSString *textString = self.text;
    
    if (textString && ![textString  isEqual:@""])
    {
        CGRect labelRect = [textString boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName : self.font}
                                                    context:nil];
        [super drawTextInRect:CGRectMake(0, 0, self.frame.size.width, ceil(labelRect.size.height))];
    }
    else
    {
        [super drawTextInRect:rect];
    }
}

@end
