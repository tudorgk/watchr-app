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
-(void) initFollowButton;
-(void) initVoteButtons;
-(void) followButtonTapped:(id)sender;
-(void) voteUpPressed:(id)sender;
-(void) voteDownPressed:(id)sender;
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
//	[self initFollowButton];
	[self initVoteButtons];

}

-(void) configureView{
	
	//set up the titleview
	_titleView = [TDEventDetailsNavigationTitleView titleViewWithTitle:[_watchrEvent objectForKey:@"event_name"] andSubtitle:@"tap here for event info"];
	_titleView.delegate = self;
	self.navigationItem.titleView = _titleView;
	
	//set delegate and data source
	[self.eventDetailsTableView setDelegate:self];
	[self.eventDetailsTableView setDataSource:self];
	

	NSMutableArray * imageURLS = [NSMutableArray new];
	for (NSDictionary * attachment in [_watchrEvent objectForKey:@"attachments"]) {
		[imageURLS addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TDAPIBaseURL,[attachment  objectForKey:@"location"] ]]];
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
}

-(void) registerNibsForTableView{
	[self.eventDetailsTableView registerNib:[UINib nibWithNibName:@"TDEventDescriptionView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"descriptionView"];
	[self.eventDetailsTableView registerNib:[UINib nibWithNibName:@"TDEventTabSelectorView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"selectorView"];
}

-(void) initDescriptionView{
	
	
	_headerView = [self.eventDetailsTableView dequeueReusableHeaderFooterViewWithIdentifier:@"descriptionView"];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc ]init];;
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate * date = [dateFormatter dateFromString:[_watchrEvent objectForKey:@"created_at"]];
	_headerView.headerEventDateLabel.text = [[TDHelperClass sharedHelper] getStringRepresentationForstartDate:date andEndDate:[NSDate date]];
	_headerView.headerEventNameLabel.text = [_watchrEvent objectForKey:@"event_name"];
	_headerView.headerCategoryIcon.image = [UIImage imageNamed:[[_watchrEvent objectForKey:@"category"] objectForKey:@"category_icon"]];
	_headerView.headerProfileNameLabel.text = [NSString stringWithFormat:@"%@ %@",[[_watchrEvent objectForKey:@"creator"] objectForKey:@"first_name"],[[_watchrEvent objectForKey:@"creator"] objectForKey:@"last_name"]];
	_headerView.headerUsernameLabel.text = [[_watchrEvent objectForKey:@"creator"] objectForKey:@"username"];
	[_headerView.headerProfileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,[[[_watchrEvent objectForKey:@"creator"] objectForKey:@"profile_photo"] objectForKey:@"location"]]] placeholderImage:[UIImage imageNamed:@"profile-photo-placeholder.png"]];
	
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

-(void) initFollowButton{
	
	_followButton = [[TDFollowButton alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
	[_followButton addTarget:self action:@selector(followButtonTapped:) forControlEvents:UIControlEventTouchUpInside]; 
	UIBarButtonItem * rightBBI = [[UIBarButtonItem alloc] initWithCustomView:_followButton];
	[self.navigationItem setRightBarButtonItem:rightBBI];
}

-(void) initVoteButtons{
	_voteUpButton = [[TDVoteButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	[_voteUpButton setButtonOffImage:[UIImage imageNamed:@"rate-up-icon-off.png"]];
	[_voteUpButton setButtonOnImage:[UIImage imageNamed:@"rate-up-icon-on.png"]];
	[_voteUpButton setButtonState:TDVoteButtonStateOff];
	[_voteUpButton addTarget:self action:@selector(voteUpPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * voteUpBBI = [[UIBarButtonItem alloc] initWithCustomView:_voteUpButton];

	
	_voteDownButton = [[TDVoteButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
	[_voteDownButton setButtonOffImage:[UIImage imageNamed:@"rate-down-icon-off.png"]];
	[_voteDownButton setButtonOnImage:[UIImage imageNamed:@"rate-down-icon-on.png"]];
	[_voteDownButton setButtonState:TDVoteButtonStateOff];
	[_voteDownButton addTarget:self action:@selector(voteDownPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * voteDownBBI = [[UIBarButtonItem alloc] initWithCustomView:_voteDownButton];

	[self.navigationItem setRightBarButtonItems:@[voteUpBBI,voteDownBBI]];
	
	if ([[_watchrEvent objectForKey:@"user_voted"] boolValue]) {
		switch ([[_watchrEvent objectForKey:@"user_vote_value"] integerValue]) {
			case 0:
			{
				[_voteDownButton setButtonState:TDVoteButtonStateOff];
				[_voteUpButton setButtonState:TDVoteButtonStateOff];
			}
				break;
			case 1:
			{
				[_voteDownButton setButtonState:TDVoteButtonStateOff];
				[_voteUpButton setButtonState:TDVoteButtonStateOn];
			}
				break;
			case -1:
			{
				[_voteDownButton setButtonState:TDVoteButtonStateOn];
				[_voteUpButton setButtonState:TDVoteButtonStateOff];
			}
				break;
				
			default:
				break;
		}
	}else{
		[_voteDownButton setButtonState:TDVoteButtonStateOff];
		[_voteUpButton setButtonState:TDVoteButtonStateOff];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Vote up/down

-(void) voteUpPressed:(id)sender{
	TDVoteButton * button = (TDVoteButton*) sender;
	[button setButtonState:(!button.buttonState)];
	[_voteDownButton setButtonState:TDVoteButtonStateOff];
	if (button.buttonState == TDVoteButtonStateOn) {
		[self sendRateRequest:1];
	}else{
		[self sendRateRequest:0];
	}
	
}

-(void) voteDownPressed:(id)sender{
	TDVoteButton * button = (TDVoteButton*) sender;
	[button setButtonState:(!button.buttonState)];
	[_voteUpButton setButtonState:TDVoteButtonStateOff];
	if (button.buttonState == TDVoteButtonStateOn) {
		[self sendRateRequest:-1];
	}else{
		[self sendRateRequest:0];
	}

}

-(void) sendRateRequest:(NSInteger) rateValue{
	
	
	//send the request
	[NXOAuth2Request performMethod:@"POST"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/events/rating"]]
				   usingParameters:@{@"rating_value" :[NSNumber numberWithInteger:rateValue],
									 @"event_id" : [NSNumber numberWithInteger:[[_watchrEvent objectForKey:@"event_id"] integerValue]]}
					   withAccount:[[NXOAuth2AccountStore sharedStore] accountWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:TDWatchrAPIAccountIdentifier] ]
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
					   NSString * responseString =[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
					   NSLog(@"responseData = %@", responseString );
					   NSLog(@"response = %@", [response description]);
					   NSLog(@"error = %@", [error userInfo]);
					   
					   //if error
					   if (error) {
						   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving events" message:[[error userInfo] description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
						   [alert show];
					   }else{
						   [[NSNotificationCenter defaultCenter] postNotificationName:TDWatchrEventDidChangeNotification object:nil];
					   }
					   
				   }];
}

#pragma mark - Follow Button

-(void) followButtonTapped:(id)sender{
	[_followButton setFollowing:(![_followButton isFollowing])];
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

#pragma mark - title view delegate methods

-(void) titleViewTapped:(TDEventDetailsNavigationTitleView *)titleView{
	NSLog(@"titleView tapped!");
	//TODO: Testing JSQMessageView Controller
	JSQDemoViewController *vc = [JSQDemoViewController messagesViewController];
	[self.navigationController pushViewController:vc animated:YES];
}


@end
