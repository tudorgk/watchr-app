//
//  TDEventTabSelectorView.m
//  watchr
//
//  Created by Tudor Dragan on 15/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventTabSelectorView.h"

@interface TDEventTabSelectorView()<DKScrollingTabControllerDelegate>{
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
	
	_leftTabController.selection = @[@"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0" ];
	[_leftTabController setButtonName:@"EVENT\nDETAILS" atIndex:0];
	[_leftTabController setButtonName:@"COMMENTS\n143" atIndex:1];
	[_leftTabController setButtonName:@"FOLLOWING\n1,092" atIndex:2];
	[_leftTabController setButtonName:@"FOLLOWERS\n924" atIndex:3];
		[_leftTabController setButtonName:@"FOLLOWERS\n924" atIndex:4];
		[_leftTabController setButtonName:@"FOLLOWERS\n924" atIndex:5];
	
	
	[_leftTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *button = obj;
		button.titleLabel.numberOfLines = 2;
		button.titleLabel.textAlignment = NSTextAlignmentCenter;
		
		NSString *buttonName = button.titleLabel.text;
		NSString *text =  [buttonName substringWithRange: NSMakeRange(0, [buttonName rangeOfString: @"\n"].location)];
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:6] };
		NSRange range = [buttonName rangeOfString:text];
		[attributedString addAttributes:attributes range:range];
		
		button.titleLabel.text = @"";
		[button setAttributedTitle:attributedString forState:UIControlStateNormal];
	}];

}

#pragma mark - TabControllerDelegate

- (void)DKScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
    NSLog(@"Selection controller action button with index=%d",selection);
	//when selected change the data source

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
