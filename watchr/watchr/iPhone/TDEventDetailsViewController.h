//
//  TDEventDetailsViewController.h
//  watchr
//
//  Created by Tudor Dragan on 22/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDEventDescriptionView.h"
#import "HeaderInsetTableView.h"
#import "TDEventDetailsDataSourceManager.h"


@interface TDEventDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet HeaderInsetTableView *eventDetailsTableView;
@property (nonatomic, strong) NSDictionary * watchrEvent;
@end
