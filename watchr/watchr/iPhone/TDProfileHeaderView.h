//
//  TDProfileHeaderView.h
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDProfileHeaderView;
@protocol TDProfileHeaderViewDelegate <NSObject>

@optional
-(void) profileHeader:(TDProfileHeaderView*) headerView profilePhotoTapped:(UIImageView*) profilePhoto;
-(void) profileHeader:(TDProfileHeaderView*) headerView usernameTapped:(UILabel*) usernameLabel;


@end
@interface TDProfileHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *customBackgroundView;
@property (nonatomic,assign) id<TDProfileHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end
