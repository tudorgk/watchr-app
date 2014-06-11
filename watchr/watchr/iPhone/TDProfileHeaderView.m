//
//  TDProfileHeaderView.m
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDProfileHeaderView.h"

@interface TDProfileHeaderView(){
	UITapGestureRecognizer * _photoTapper ,* _labelTapper;
}

-(void) userDidTapProfilePhoto;
-(void) userDidTapUsernameLabel;

@end

@implementation TDProfileHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib{
	[super awakeFromNib];
	//add gesture recognizers to imageview and label
	_photoTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapProfilePhoto)];
	[self.profileImageView addGestureRecognizer:_photoTapper];
	
	_labelTapper= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapUsernameLabel)];
	[self.usernameLabel addGestureRecognizer:_labelTapper];
}

-(void) userDidTapProfilePhoto{
	if (_delegate!=nil) {
		if ([_delegate respondsToSelector:@selector(profileHeader:profilePhotoTapped:)]) {
			[_delegate profileHeader:self profilePhotoTapped:self.profileImageView];
		}
	}
}
-(void) userDidTapUsernameLabel{
	if (_delegate!=nil) {
		if ([_delegate respondsToSelector:@selector(profileHeader:usernameTapped:)]) {
			[_delegate profileHeader:self usernameTapped:self.usernameLabel];
		}
	}
}


@end
