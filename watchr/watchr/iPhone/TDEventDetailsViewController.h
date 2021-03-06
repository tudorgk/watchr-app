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
#import "TDEventTabSelectorView.h"
#import "TDEventStatusTableViewCell.h"
#import "TDEventDescriptionTableViewCell.h"
#import "TDEventMapTableViewCell.h"
#import "TDEventDetailsNavigationTitleView.h"
#import "TDFollowButton.h"
#import "TDVoteButton.h"
@interface TDEventDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,TDEventDetailsNavigationTitleViewDelegate>{
	TDEventDescriptionView * _headerView;
	TDEventTabSelectorView * _selectorView;
	
	//Custom static cells
	TDEventDescriptionTableViewCell * _descriptionCell;
	TDEventStatusTableViewCell * _statusCell;
	TDEventMapTableViewCell * _mapCell;
	
	//title View
	TDEventDetailsNavigationTitleView * _titleView;
	TDFollowButton *_followButton;
	TDVoteButton *_voteUpButton;
	TDVoteButton * _voteDownButton;
}

@property (weak, nonatomic) IBOutlet HeaderInsetTableView *eventDetailsTableView;
@property (nonatomic, strong) NSMutableDictionary * watchrEvent;
@end
