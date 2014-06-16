//
//  TDEventDescriptionTableViewCell.h
//  watchr
//
//  Created by Tudor Dragan on 16/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTSTextView.h"
@interface TDEventDescriptionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *cellDescription;

@end
