//
//  TDEventDetailsViewController.h
//  watchr
//
//  Created by Tudor Dragan on 22/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDEventDescriptionViewController.h"
@interface TDEventDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *eventDetailsTableView;
@property (nonatomic,strong) TDEventDescriptionViewController * eventDescriptionView;
@end
