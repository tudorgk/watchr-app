//
//  TDCategorySelectorViewController.h
//  watchr
//
//  Created by Tudor Dragan on 11/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDCategorySelectorViewController;
@protocol TDCategorySelectorDelegate <NSObject>

-(void) categorySelector:(TDCategorySelectorViewController*) categorySelectorViewController didSelectCategory:(NSDictionary*) category;

@end
@interface TDCategorySelectorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
	NSMutableArray * _categoryArray;
	UIRefreshControl * _refreshControl;
}
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (nonatomic,strong) NSDictionary * currentCategory;
@property (nonatomic,assign) id<TDCategorySelectorDelegate> delegate;
@end
