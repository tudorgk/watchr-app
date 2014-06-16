//
//  TDEventDescriptionView.h
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILTranslucentView.h"
@interface TDEventDescriptionView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet ILTranslucentView *translucentBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *headerProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerProfileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerEventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerEventNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerCategoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *headerEventAddressLabel;

@end
