//
//  TDDashboardEventTableViewCell.h
//  watchr
//
//  Created by Tudor Dragan on 20/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDDashboardEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellRatingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellEventImportanceImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellEventDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellEventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellEventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellTimeLabel;

@end
