//
//  TDMapSelectorTableViewCell.h
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface TDMapSelectorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cellMyLocationButton;
@property (weak, nonatomic) IBOutlet MKMapView *cellPreviewMap;

@end
