//
//  TDSideMenuViewController.h
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSideMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
	NSMutableArray * _menuEntries;
}
@property (weak, nonatomic) IBOutlet UITableView *sideMenuTableView;

@end
