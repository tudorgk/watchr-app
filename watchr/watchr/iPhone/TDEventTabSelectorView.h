//
//  TDEventTabSelectorView.h
//  watchr
//
//  Created by Tudor Dragan on 15/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKScrollingTabController.h"
@interface TDEventTabSelectorView : UITableViewHeaderFooterView
@property (nonatomic,strong) DKScrollingTabController * leftTabController;
@end
