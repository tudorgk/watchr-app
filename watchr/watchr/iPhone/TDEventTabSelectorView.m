//
//  TDEventTabSelectorView.m
//  watchr
//
//  Created by Tudor Dragan on 15/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventTabSelectorView.h"

@interface TDEventTabSelectorView(){
}
@end
@implementation TDEventTabSelectorView


-(void) awakeFromNib{
	[super awakeFromNib];
	self.contentView.backgroundColor = [UIColor lightGrayColor];
	
	_leftTabController = [[DKScrollingTabController alloc] init];
	
	_leftTabController.delegate = self;
	[self addSubview:_leftTabController.view];
	_leftTabController.view.frame = self.bounds;
	
	_leftTabController.view.backgroundColor = [UIColor whiteColor];
	
	// Add a bottomBorder.
	CALayer *bottomBorder = [CALayer layer];
	
	bottomBorder.frame = CGRectMake(0.0f, _leftTabController.view.frame.size.height, _leftTabController.view.frame.size.width, 1.0f);
	
	bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
													 alpha:1.0f].CGColor;
	
	[_leftTabController.view.layer addSublayer:bottomBorder];
	
	_leftTabController.buttonPadding = 10;
	_leftTabController.underlineIndicator = YES;
	_leftTabController.underlineIndicatorColor = [UIColor redColor];
	_leftTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
	_leftTabController.selectedBackgroundColor = [UIColor clearColor];
	_leftTabController.selectedTextColor = [UIColor blackColor];
	_leftTabController.unselectedTextColor = [UIColor grayColor];
	_leftTabController.unselectedBackgroundColor = [UIColor clearColor];
	_leftTabController.translucent = YES;
	
	

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
