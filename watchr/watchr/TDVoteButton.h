//
//  TDVoteUpButton.h
//  watchr
//
//  Created by Tudor Dragan on 23/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	TDVoteButtonStateOff = 0,
	TDVoteButtonStateOn = 1
}TDVoteButtonState;

@interface TDVoteButton : UIButton

@property (nonatomic) TDVoteButtonState buttonState;
@property (nonatomic,strong) UIImage *buttonOnImage;
@property (nonatomic,strong) UIImage *buttonOffImage;

@end
