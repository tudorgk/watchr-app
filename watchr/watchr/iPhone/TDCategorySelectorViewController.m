//
//  TDCategorySelectorViewController.m
//  watchr
//
//  Created by Tudor Dragan on 11/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDCategorySelectorViewController.h"

@interface TDCategorySelectorViewController (){
	UIBarButtonItem *_saveBarButtonItem;
}

-(void) configureTableView;
-(void) refreshTable;
-(void) userDidSaveCategory;
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
	
	//Add the save button. Set it hidden until the categories have been downloaded
	_saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(userDidSaveCategory)];
	self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
	[_saveBarButtonItem setEnabled:NO];
	
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
					   
					   //find the default subcategory (category_id = 1)
					   for (int i = 0 ; i<[_categoryArray count]; i++) {
						   NSArray *subCategoryArray = [[_categoryArray objectAtIndex:i] objectForKey:@"subcategories"];
						   for (int j=0; j<[subCategoryArray count]; j++) {
							   NSDictionary * subcategory = [subCategoryArray objectAtIndex:j];
							   if([[subcategory objectForKey:@"category_id"] intValue] == 1){
								   self.currentCategory = subcategory;
							   }
						   }
					   }
					   
					   [self.categoryTableView reloadData];
					   [_saveBarButtonItem setEnabled:YES];
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
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
	NSInteger mainCategoryIndex = 0;
	NSInteger subCategoryIndex = 0;
	
	//find the current subcategory
	for (int i = 0 ; i<[_categoryArray count]; i++) {
		NSArray *subCategoryArray = [[_categoryArray objectAtIndex:i] objectForKey:@"subcategories"];
		for (int j=0; j<[subCategoryArray count]; j++) {
			if ([self.currentCategory isEqual:[subCategoryArray objectAtIndex:j]]) {
				mainCategoryIndex = i;
				subCategoryIndex = j;
			}
		}
	}
	
	if (mainCategoryIndex == indexPath.section && subCategoryIndex == indexPath.row) {
		//it's the same. no need to reselect
        return;
    }
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:subCategoryIndex inSection:mainCategoryIndex];
	
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentCategory = [[[_categoryArray objectAtIndex:indexPath.section] objectForKey:@"subcategories"] objectAtIndex:indexPath.row];
    }
	
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
	
	NSArray * mainCategoryItemSubcategories = [[_categoryArray objectAtIndex:indexPath.section] objectForKey:@"subcategories"];
	NSDictionary * categoryItem = [mainCategoryItemSubcategories objectAtIndex:indexPath.row];
	
	if ([categoryItem isEqual:self.currentCategory]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.textLabel.text = [categoryItem objectForKey:@"category_name"];
	cell.detailTextLabel.text = [categoryItem objectForKey:@"category_description"];
	[cell.imageView setImage:[UIImage imageNamed:[categoryItem objectForKey:@"category_icon"]]];
	[cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[[_categoryArray objectAtIndex:section] objectForKey:@"subcategories"] count];
}
#pragma mark - Saving

-(void) userDidSaveCategory{
	if (_delegate) {
		if ([_delegate respondsToSelector:@selector(categorySelector:didSelectCategory:)]) {
			[_delegate categorySelector:self didSelectCategory:self.currentCategory];
		}
	}
}

@end
