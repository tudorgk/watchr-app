//
//  TDCategorySelectorViewController.h
//  watchr
//
//  Created by Tudor Dragan on 11/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDCategorySelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray * _categoryArray;
	UIRefreshControl * _refreshControl;
}
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

@end
