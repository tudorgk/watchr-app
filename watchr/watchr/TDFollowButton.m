//
//  TDFollowButton.m
//  watchr
//
//  Created by Tudor Dragan on 22/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDFollowButton.h"

@interface TDFollowButton(){
	
}

@end

@implementation TDFollowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		self.layer.borderColor = [[UIColor whiteColor] CGColor];
		self.layer.backgroundColor = [[UIColor clearColor] CGColor];
		self.layer.borderWidth = 1;
		self.layer.cornerRadius = 5;
		self.clipsToBounds = YES;
		
		NSString *buttonName =@"Follow+";
		
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
									  NSForegroundColorAttributeName : [UIColor whiteColor]};
		NSRange range = [buttonName rangeOfString:buttonName];
		[attributedString addAttributes:attributes range:range];
		
		[self setAttributedTitle:attributedString forState:UIControlStateNormal];
	
		
		_following = NO;

    }
    return self;
}

-(BOOL) isFollowing{
	return _following;
}

-(void) setFollowing:(BOOL)following{
	_following= following;
	if (following) {
		self.layer.backgroundColor = [[UIColor whiteColor] CGColor];

		NSString *buttonName =@"Following";
		
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
									  NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:164.0f/255.0f blue:249.0f/255.0f alpha:1.0f]};
		NSRange range = [buttonName rangeOfString:buttonName];
		[attributedString addAttributes:attributes range:range];
		
		[self setAttributedTitle:attributedString forState:UIControlStateNormal];
	}else{
		self.layer.backgroundColor = [[UIColor clearColor] CGColor];
		
		NSString *buttonName =@"Follow+";
		
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12],
									  NSForegroundColorAttributeName : [UIColor whiteColor]};
		NSRange range = [buttonName rangeOfString:buttonName];
		[attributedString addAttributes:attributes range:range];
		
		[self setAttributedTitle:attributedString forState:UIControlStateNormal];
		
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
