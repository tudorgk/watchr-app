//
//  TDEventDetailsViewController.m
//  watchr
//
//  Created by Tudor Dragan on 22/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDEventDetailsViewController.h"
#import "TDCarouselView.h"
#import "UILabel+dynamicSizeMe.h"
#import "TDAnnotation.h"
#import "JSQMessages.h"
#import "JSQDemoViewController.h"
typedef enum {
	TDEventActiveDataSourceDetails = 0,
	TDEventActiveDataSourceComments = 1,
	TDEventActiveDataSourceMap = 2,
	TDEventActiveDataSourceFollowers = 3
} TDEventActiveDataSource;


@interface TDEventDetailsViewController ()<MKMapViewDelegate>{
	TDEventActiveDataSource _activeDataSource;
}
-(void) configureView;
-(void) initDescriptionView;
-(void) initTabSelectorView;
-(void) registerNibsForTableView;
-(void) initCells;

@end

@implementation TDEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) awakeFromNib{
	[super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"watchr event = %@", _watchrEvent);
	
	_activeDataSource = TDEventActiveDataSourceDetails;
	

	[self configureView];
	[self registerNibsForTableView];
	[self initCells];
	[self initDescriptionView];
	[self initTabSelectorView];

}

-(void) configureView{
	//set delegate and data source
	[self.eventDetailsTableView setDelegate:self];
	[self.eventDetailsTableView setDataSource:self];
	

	NSMutableArray * imageURLS = [NSMutableArray new];
	for (NSDictionary * attachment in [_watchrEvent objectForKey:@"attachments"]) {
		[imageURLS addObject:[NSURL URLWithString:[attachment objectForKey:@"location"]]];
	}
	
	if ([imageURLS count] != 0) {
		TDCarouselView * carousel = [[TDCarouselView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) andImageURLs:imageURLS];
		//add Parallax View to tableView
		[self.eventDetailsTableView addParallaxWithView:carousel andHeight:100];
		[self.eventDetailsTableView setHeaderViewInsets:UIEdgeInsetsMake(-160, 0, 0, 0)]; // Content inset's opposite for this example
	}else{
		
	}
	
		
	
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:YES];
	
	//TODO: Testing JSQMessageView Controller
//	JSQDemoViewController *vc = [JSQDemoViewController messagesViewController];
//	[self.navigationController pushViewController:vc animated:YES];

}

-(void) registerNibsForTableView{
	[self.eventDetailsTableView registerNib:[UINib nibWithNibName:@"TDEventDescriptionView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"descriptionView"];
	[self.eventDetailsTableView registerNib:[UINib nibWithNibName:@"TDEventTabSelectorView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"selectorView"];
}

-(void) initDescriptionView{
	
	
	_headerView = [self.eventDetailsTableView dequeueReusableHeaderFooterViewWithIdentifier:@"descriptionView"];
	
	_headerView.headerEventDateLabel.text = [_watchrEvent objectForKey:@"created_at"];
	_headerView.headerEventNameLabel.text = [_watchrEvent objectForKey:@"event_name"];
	_headerView.headerCategoryIcon.image = [UIImage imageNamed:[[_watchrEvent objectForKey:@"category"] objectForKey:@"category_icon"]];
	_headerView.headerProfileNameLabel.text = [[_watchrEvent objectForKey:@"creator"] objectForKey:@"last_name"];
	_headerView.headerUsernameLabel.text = [[_watchrEvent objectForKey:@"creator"] objectForKey:@"username"];
	
	CLGeocoder * geocoder = [CLGeocoder new];
	
	CLLocationCoordinate2D eventCoordinates = CLLocationCoordinate2DMake([[[_watchrEvent objectForKey:@"position"] objectForKey:@"latitude"] doubleValue], [[[_watchrEvent objectForKey:@"position"] objectForKey:@"longitude"] doubleValue]);
	CLLocation * eventLocation = [[CLLocation alloc] initWithLatitude:eventCoordinates.latitude longitude:eventCoordinates.longitude];
	//setup the label
	[geocoder reverseGeocodeLocation:eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark * placemark = [placemarks firstObject];
		_headerView.headerEventAddressLabel.text = placemark.name;
	}];
	self.eventDetailsTableView.tableHeaderView = _headerView;
	
	

}

-(void) initTabSelectorView{
	
	_selectorView = [self.eventDetailsTableView	dequeueReusableHeaderFooterViewWithIdentifier:@"selectorView"];
	
	//set delegate
	_selectorView.leftTabController.delegate = self;
	
	//set buttons
	_selectorView.leftTabController.selection = @[@"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0" ];
	[_selectorView.leftTabController setButtonName:@"EVENT\nDETAILS" atIndex:0];
	[_selectorView.leftTabController setButtonName:@"SHOW\nMAP" atIndex:1];
	[_selectorView.leftTabController setButtonName:@"COMMENTS\n143" atIndex:2];
	[_selectorView.leftTabController setButtonName:@"FOLLOWERS\n924" atIndex:3];
	
	[_selectorView.leftTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *button = obj;
		button.titleLabel.numberOfLines = 2;
		button.titleLabel.textAlignment = NSTextAlignmentCenter;
		
		NSString *buttonName = button.titleLabel.text;
		NSString *text =  [buttonName substringWithRange: NSMakeRange(0, [buttonName rangeOfString: @"\n"].location)];
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:6] };
		NSRange range = [buttonName rangeOfString:text];
		[attributedString addAttributes:attributes range:range];
		
		button.titleLabel.text = @"";
		[button setAttributedTitle:attributedString forState:UIControlStateNormal];
	}];
	
}

-(void) initCells{
	
	//STATUS CELL
	_statusCell = (TDEventStatusTableViewCell*) [self.eventDetailsTableView dequeueReusableCellWithIdentifier:@"statusCell"];
	//TODO: Implement Event status mesages
	
	//DESCRIPTION CELL
	_descriptionCell = (TDEventDescriptionTableViewCell*) [self.eventDetailsTableView dequeueReusableCellWithIdentifier:@"descriptionCell"];
	NSString *description = [_watchrEvent objectForKey:@"description"];
	CGRect descriptionFrame = [_descriptionCell.cellDescription frame];
	[_descriptionCell.cellDescription setText:description];
	descriptionFrame.size.height = [self measureHeightOfUITextView:_descriptionCell.cellDescription];
	[_descriptionCell.cellDescription setFrame:descriptionFrame];
	
	//MAP CELL
	_mapCell = (TDEventMapTableViewCell*) [self.eventDetailsTableView dequeueReusableCellWithIdentifier:@"mapCell"];
	_mapCell.cellMapView.delegate =self;
	CLLocationCoordinate2D eventCoordinates = CLLocationCoordinate2DMake([[[_watchrEvent objectForKey:@"position"] objectForKey:@"latitude"] doubleValue], [[[_watchrEvent objectForKey:@"position"] objectForKey:@"longitude"] doubleValue]);
	MKCoordinateRegion adjustedRegion = [_mapCell.cellMapView regionThatFits:MKCoordinateRegionMakeWithDistance(eventCoordinates, 200, 200)];
	[_mapCell.cellMapView setRegion:adjustedRegion animated:NO];
	
	
	TDAnnotation * eventAnnotation = [[TDAnnotation alloc] initWithCoordinate:eventCoordinates title:[_watchrEvent objectForKey:@"event_name"] andAddress:@"address"];
	[_mapCell.cellMapView addAnnotation:eventAnnotation];
	
	
	CLGeocoder * geocoder = [CLGeocoder new];
	CLLocation * eventLocation = [[CLLocation alloc] initWithLatitude:eventCoordinates.latitude longitude:eventCoordinates.longitude];
	[geocoder reverseGeocodeLocation:eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark * placemark = [placemarks firstObject];
		eventAnnotation.subtitle = placemark.name;
	
	}];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	return _selectorView;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 44;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (_activeDataSource) {
		case TDEventActiveDataSourceDetails:
		{
			if (indexPath.row == 0) {
				return 44;
			}else{
//				CGRect textViewFrame = _descriptionCell.cellDescriptionTextView.frame;
//				
//				textViewFrame.size.height = [self heightForTextView:_descriptionCell.cellDescriptionTextView containingString:[_watchrEvent objectForKey:@"description"]];
//				
//				[_descriptionCell.cellDescriptionTextView setFrame:textViewFrame];
//				
//				
//				return textViewFrame.size.height + 90;
				
				return [self measureHeightOfUITextView:_descriptionCell.cellDescription] + 40;
			}
		}
			break;
		case TDEventActiveDataSourceMap:
		{
			return self.view.frame.size.height - 44.0f - 60.0f;
		}
			break;
		default:
			break;
	}
	return 0;
}

#pragma mark - UITableViewDataSource Methods


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (_activeDataSource) {
		case TDEventActiveDataSourceDetails:
		{
			if (indexPath.row == 0) {
				return _statusCell;
			}else if (indexPath.row == 1){
				return _descriptionCell;
			}
		}
			break;
		case TDEventActiveDataSourceMap:
		{
			return _mapCell;
		}
			break;
		default:
			break;
	}
	return [UITableViewCell new];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (_activeDataSource) {
		case TDEventActiveDataSourceDetails:
		{
			return 2;
		}
			break;
		case TDEventActiveDataSourceMap:
		{
			return 1;
		}
			break;
		default:
			break;
	}
	return 0;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}




#pragma mark - Helpers


- (CGFloat)heightForTextView:(UIView*)textView containingString:(NSString*)string
{
	
	CGSize maximumLabelSize = CGSizeMake(textView.bounds.size.width, FLT_MAX);
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByCharWrapping];
	
	NSDictionary * stringAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14],
										NSParagraphStyleAttributeName: style};
	
	CGSize textViewSize = [string boundingRectWithSize:maximumLabelSize
											   options:NSStringDrawingUsesLineFragmentOrigin
											attributes:stringAttributes context:nil].size;
	

    return textViewSize.height + 14;
}


- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
		
        CGRect frame = textView.bounds;
		
        // Take account of the padding added around the text.
		
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
		
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
		
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
		
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
		
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
		
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
		
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
		
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
		
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}


#pragma mark - TabControllerDelegate

- (void)DKScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
    NSLog(@"Selection controller action button with index=%d",selection);
	//when selected change the data source
	switch (selection) {
		case 0:
		{
			_activeDataSource = TDEventActiveDataSourceDetails;
			[self.eventDetailsTableView reloadData];
			[self.eventDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			[self.eventDetailsTableView setScrollEnabled:YES];
		}
			break;
		case 1:
		{
			_activeDataSource = TDEventActiveDataSourceMap;
			[self.eventDetailsTableView reloadData];
			[self.eventDetailsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
			[self.eventDetailsTableView setScrollEnabled:NO];
			CLLocationCoordinate2D eventLocation = CLLocationCoordinate2DMake([[[_watchrEvent objectForKey:@"position"] objectForKey:@"latitude"] doubleValue], [[[_watchrEvent objectForKey:@"position"] objectForKey:@"longitude"] doubleValue]);
			MKCoordinateRegion adjustedRegion = [_mapCell.cellMapView regionThatFits:MKCoordinateRegionMakeWithDistance(eventLocation, 200, 200)];
			[_mapCell.cellMapView setRegion:adjustedRegion animated:YES];
		}
			break;
			
		default:
			break;
	}

}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
	if ([annotation isKindOfClass:[MKUserLocation class]]){
		return nil;
	}else{
		static NSString *const reuseID = @"eventLocationReuseID";
		

		MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[_mapCell.cellMapView dequeueReusableAnnotationViewWithIdentifier:reuseID];
		
		if (!annotationView) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseID];
		}
		
		annotationView.canShowCallout = YES;

		return annotationView;
		
	}
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{

}




@end
