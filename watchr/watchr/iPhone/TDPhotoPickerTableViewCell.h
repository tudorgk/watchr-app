//
//  TDPhotoPickerTableViewCell.h
//  watchr
//
//  Created by Tudor Dragan on 30/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDPhotoPickerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellMessageLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *cellThumbnailsScrollView;
@end
