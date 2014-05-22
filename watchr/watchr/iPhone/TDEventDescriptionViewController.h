//
//  TDEventDescriptionViewController.h
//  watchr
//
//  Created by Tudor Dragan on 22/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDEventDescriptionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *enevtTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@end
