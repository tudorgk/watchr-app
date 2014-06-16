//
//  TDEventDescriptionView.m
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventDescriptionView.h"

@implementation TDEventDescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) awakeFromNib{
	CGFloat cornerRadius = 6.0f;
    
    self.headerProfileImageView.layer.backgroundColor = (__bridge CGColorRef)([UIColor whiteColor]);
    self.headerProfileImageView.layer.borderWidth = 0.5f;
    self.headerProfileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.headerProfileImageView.layer.cornerRadius = cornerRadius;
	self.headerProfileImageView.clipsToBounds= YES;

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
