//
//  TDEventStatusTableViewCell.m
//  watchr
//
//  Created by Tudor Dragan on 16/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventStatusTableViewCell.h"

@implementation TDEventStatusTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	_cellStatusLabelHolderView.layer.cornerRadius = 5.0f;
	_cellStatusLabelHolderView.clipsToBounds= YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
