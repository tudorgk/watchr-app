//
//  TDDashboardFilterButton.m
//  watchr
//
//  Created by Tudor Dragan on 20/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDDashboardFilterButton.h"

@implementation TDDashboardFilterButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
		NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style setAlignment:NSTextAlignmentLeft];
		[style setLineBreakMode:NSLineBreakByWordWrapping];
		
		UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light"  size:14.0f];
		NSDictionary *dict = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
							   NSFontAttributeName:font,
							   NSParagraphStyleAttributeName:style,
							   NSForegroundColorAttributeName:[UIColor darkGrayColor]
							   };
		UIColor * tintColor = [UIColor colorWithRed:0 green:164.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
		
		//radius button
		
		[self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
		[self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
		NSAttributedString * radiusAttrString =[[NSAttributedString alloc] initWithString:@"Button"attributes:dict];
		[self setAttributedTitle:radiusAttrString forState:UIControlStateNormal];
		[self.titleLabel setAdjustsFontSizeToFitWidth:YES];
		[self.titleLabel setMinimumScaleFactor:0.5f];
		[self.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[self.titleLabel setNumberOfLines:1];
		[self setTintColor:tintColor];

		
    }
    return self;
}

-(void) setCustomTitle:(NSString*) title forControlState:(UIControlState) state{
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setAlignment:NSTextAlignmentCenter];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	
	UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light"  size:14.0f];
	NSDictionary *dict = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
						   NSFontAttributeName:font,
						   NSParagraphStyleAttributeName:style,
						   NSForegroundColorAttributeName:[UIColor darkGrayColor]
						   };

	NSAttributedString * radiusAttrString =[[NSAttributedString alloc] initWithString:title attributes:dict];
	[self setAttributedTitle:radiusAttrString forState:state];
	[self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	[self setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
