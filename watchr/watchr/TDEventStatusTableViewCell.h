//
//  TDEventStatusTableViewCell.h
//  watchr
//
//  Created by Tudor Dragan on 16/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDEventStatusTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *cellStatusLabelHolderView;
@property (weak, nonatomic) IBOutlet UILabel *cellStatusLabel;

@end
