//
//  TDVoteUpButton.m
//  watchr
//
//  Created by Tudor Dragan on 23/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDVoteButton.h"

@implementation TDVoteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_buttonState = TDVoteButtonStateOff;
		
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void) setButtonState:(TDVoteButtonState)buttonState{
	_buttonState = buttonState;
	if (_buttonState == TDVoteButtonStateOff) {
		[self setImage:_buttonOffImage forState:UIControlStateNormal];
	}else{
		[self setImage:_buttonOnImage forState:UIControlStateNormal];
	}
	
	
}



@end
