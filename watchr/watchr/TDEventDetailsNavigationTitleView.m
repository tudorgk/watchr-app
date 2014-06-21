//
//  TDEventDetailsNavigationTitleView.m
//  watchr
//
//  Created by Tudor Dragan on 20/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventDetailsNavigationTitleView.h"

@interface TDEventDetailsNavigationTitleView()

-(void) userTappedTitleView;

@end

@implementation TDEventDetailsNavigationTitleView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		// Initialization code
    }
    return self;
}

+(TDEventDetailsNavigationTitleView*) titleViewWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle{
	TDEventDetailsNavigationTitleView * titleView = [[TDEventDetailsNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
	[titleView setBackgroundColor:[UIColor clearColor]];
	[titleView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
	
	CGRect viewFrame = titleView.frame;
	
	//set up the title label;
	UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height*2/3)];
	[titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
	[titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]];
	[titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	[titleLabel setNumberOfLines:1];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setMinimumScaleFactor:0.7f];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setText:title];
	titleView.titleLabel = titleLabel;
	[titleView addSubview:titleView.titleLabel];
	
	//set up the title label;
	UILabel * subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewFrame.origin.x, titleView.titleLabel.frame.size.height -10, viewFrame.size.width, viewFrame.size.height*1/3 + 10)];
	[subtitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
	[subtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
	[subtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	[subtitleLabel setTextAlignment:NSTextAlignmentCenter];
	[subtitleLabel setNumberOfLines:1];
	[subtitleLabel setMinimumScaleFactor:0.7f];
	[subtitleLabel setTextColor:[UIColor whiteColor]];
	[subtitleLabel setText:subtitle];
	titleView.subtitleLabel = subtitleLabel;
	[titleView addSubview:titleView.subtitleLabel];
	
	UITapGestureRecognizer * tapper = [[UITapGestureRecognizer alloc] initWithTarget:titleView action:@selector(userTappedTitleView)];
	[titleView addGestureRecognizer:tapper];
	
	return titleView;
}


-(void) userTappedTitleView{
	if(_delegate!=nil){
		if([_delegate respondsToSelector:@selector(titleViewTapped:)])
			[_delegate titleViewTapped:self];
	}
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
