//
//  TDMapSelectorTableViewCell.m
//  watchr
//
//  Created by Tudor Dragan on 29/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDMapSelectorTableViewCell.h"

@interface TDMapSelectorTableViewCell(){
	UITapGestureRecognizer * _mapTapGestureRecognizer;
}

@end

@implementation TDMapSelectorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	if (_mapTapGestureRecognizer == nil) {
		_mapTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewMapTapped:)];
		[self.cellPreviewMap addGestureRecognizer:_mapTapGestureRecognizer];
	}
	
	CLLocationCoordinate2D userLocation = self.cellPreviewMap.userLocation.location.coordinate;
	MKCoordinateRegion adjustedRegion = [self.cellPreviewMap regionThatFits:MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)];
	[self.cellPreviewMap setRegion:adjustedRegion animated:YES];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)myLocationButtonPressed:(id)sender {
	if(_delegate!=nil){
		if([_delegate respondsToSelector:@selector(mapSelectorCell:myLocationButtonPressed:)])
			[_delegate mapSelectorCell:self myLocationButtonPressed:sender];
	}
	
}

-(IBAction)previewMapTapped:(id)sender{
	if(_delegate!=nil){
		if([_delegate respondsToSelector:@selector(mapSelectorCell:mapTapped:)])
			[_delegate mapSelectorCell:self mapTapped:sender];
	}
	
}


@end
