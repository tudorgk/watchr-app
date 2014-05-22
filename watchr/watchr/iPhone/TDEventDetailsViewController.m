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
@interface TDEventDetailsViewController ()
-(void) configureView;
-(void) initDescriptionView;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self configureView];
	
	
}

-(void) configureView{
	//set delegate and data source
	[self.eventDetailsTableView setDelegate:self];
	[self.eventDetailsTableView setDataSource:self];
	
	//initiate a Carousel View with images
	NSArray * images = @[[NSURL URLWithString:@"http://www.highsnobiety.com/files/2013/05/lamborghini-egoista-concept-car-9.jpg"], [NSURL URLWithString:@"http://d1piko3ylsjhpd.cloudfront.net/uploads/roboto/image/shared_content_image/2877/large_0709-stanford-car-01.jpg"]];
	TDCarouselView * carousel = [[TDCarouselView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150) andImageURLs:images];
	
	//add Parallax View to tableView
	[self.eventDetailsTableView addParallaxWithView:carousel andHeight:150];
	
	[self initDescriptionView];
	
}

-(void) initDescriptionView{
	self.eventDescriptionView = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDescriptionView"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	TDEventDetailsViewController * detailsController = [[UIStoryboard storyboardWithName:@"EventStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
	[self.navigationController pushViewController:detailsController animated:YES];
	
}

#pragma mark - UITableViewDataSource Methods

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	return self.eventDescriptionView.view;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 10;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 300;
}


@end
