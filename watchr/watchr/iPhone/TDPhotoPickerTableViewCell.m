//
//  TDPhotoPickerTableViewCell.m
//  watchr
//
//  Created by Tudor Dragan on 30/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDPhotoPickerTableViewCell.h"

@implementation TDPhotoPickerTableViewCell

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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
