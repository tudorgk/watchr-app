//
//  TDCategorySelectorViewController.m
//  watchr
//
//  Created by Tudor Dragan on 11/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDCategorySelectorViewController.h"

@interface TDCategorySelectorViewController ()

-(void) configureTableView;
-(void) refreshTable;
@end

@implementation TDCategorySelectorViewController

-(id)init{
	self = [super init];
	if (self) {
		_categoryArray = [NSMutableArray new];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) awakeFromNib{
	_categoryArray = [NSMutableArray new];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Categories";
	
	[self configureTableView];
    // Do any additional setup after loading the view.
}

-(void) configureTableView{
	self.categoryTableView.delegate = self;
	self.categoryTableView.dataSource = self;
	
	_refreshControl = [[UIRefreshControl alloc]init];
    [self.categoryTableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}


-(void)viewDidAppear:(BOOL)animated{
	[self refreshTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Refersh Control

-(void) refreshTable{
	NSLog(@"refreshing");
	
	[NXOAuth2Request performMethod:@"GET"
						onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TDAPIBaseURL,@"/category/structured"]]
				   usingParameters:nil
					   withAccount:[[TDWatchrAPIManager sharedManager] defaultWatchrAccount]
			   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
				   NSLog(@"sent/total = %llu/%llu",bytesSend,bytesTotal);
			   }
				   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
//						NSLog(@"response = %@", [response description]);
//						NSLog(@"error = %@", [error userInfo]);
//						NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//						NSLog(@"response = %@", responseString);
					   
					   if (error) {
						   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving categories" message:[[error userInfo] description] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
						   [alert show];
					   }
					   
					   NSArray *responseArray = [[TDWatchrAPIManager sharedManager] getArrayForKey:@"data" fromResponseData:responseData];
					   _categoryArray = [NSMutableArray arrayWithArray:responseArray];
					   [self.categoryTableView reloadData];
					   
					   [_refreshControl endRefreshing];
				   }];

	

}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_categoryArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[_categoryArray objectAtIndex:section] objectForKey:@"category_name"];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Reflect selection in data model
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Reflect deselection in data model
    }
}

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
	
	NSArray * mainCategoryItemSubcategories = [[_categoryArray objectAtIndex:indexPath.section] objectForKey:@"subcategories"];
	NSDictionary * categoryItem = [mainCategoryItemSubcategories objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [categoryItem objectForKey:@"category_name"];
	cell.detailTextLabel.text = [categoryItem objectForKey:@"category_description"];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[[_categoryArray objectAtIndex:section] objectForKey:@"subcategories"] count];
}
@end
