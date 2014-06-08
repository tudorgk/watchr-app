//
//  TDAddEventViewController.h
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface TDAddEventViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>{
	MKPointAnnotation * _watchrEventPoint;
}
@property (weak, nonatomic) IBOutlet UITableView *addEventTableView;

@end
