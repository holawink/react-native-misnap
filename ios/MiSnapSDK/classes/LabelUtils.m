//
//  LabelUtils.m
//  SampleApp
//
//  Created by Jeremy Jessup on 6/2/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#import "LabelUtils.h"
#import "AutosizeLabel.h"
#import <UIKit/UIKit.h>

@implementation LabelUtils

+ (void)resizeLabels:(NSArray*)labelArray
{
	NSString *longString;
	for (int i = 0; i < labelArray.count; ++i)
	{
		UILabel *label = labelArray[i];
		if (longString.length < label.text.length)
		{
			longString = label.text;
		}
	}
	
	if (longString.length > 0)
	{
		for (int i = 0; i < labelArray.count; ++i)
		{
            AutosizeLabel *label = (AutosizeLabel *)labelArray[i];
			[label resizeFontSize:longString];
		}
	}
}

@end
