//
//  TDSideMenuViewController.m
//  watchr
//
//  Created by Tudor Dragan on 23/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDSideMenuViewController.h"
#import "TDProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "TDWelcomeScreenViewController.h"
@interface TDSideMenuViewController()<TDProfileHeaderViewDelegate>{
	int * _selectedRow;
	
	NSDictionary * _userInformation;
}
-(void) configureView;
-(void) configureTableView;
-(void) registerForNotifications;
@end

@implementation TDSideMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];

	@try {
		NSData * userInformationData = [[NSUserDefaults standardUserDefaults ] objectForKey:TDWatchrLoggedInUserInformationKey];
		NSError * JSONParsingError = nil;
		id JSONObject = [NSJSONSerialization
						 JSONObjectWithData:userInformationData
						 options:NSJSONReadingMutableContainers
						 error:&JSONParsingError];
		
		if (JSONParsingError !=nil) {
			NSLog(@"Error retrieving user information");
		}else{
			_userInformation = [[JSONObject objectForKey:@"data"] copy];
			[_sideMenuTableView reloadData];
		}
		
	}
	@catch (NSException *exception) {
		_userInformation = nil;
	}
	@finally {
		
	}
	
	[self configureView];
	[self configureTableView];
	[self registerForNotifications];

}

-(void) configureView{
	self.sideMenuTableView.delegate = self;
	self.sideMenuTableView.dataSource = self;
	
	self.edgesForExtendedLayout=UIRectEdgeNone;
	self.extendedLayoutIncludesOpaqueBars=NO;
	self.automaticallyAdjustsScrollViewInsets=NO;
}

-(void) viewWillAppear:(BOOL)animated{
	
	
}

-(void) configureTableView{
	
	[self.sideMenuTableView registerNib:[UINib nibWithNibName:@"TDProfileHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"profileHeader"];
	
	_menuEntries = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuItems" ofType:@"plist"]];

	//set the first row to selected
	_selectedRow = (int*) calloc(_menuEntries.count, sizeof(int));
	_selectedRow[0]= 1;
}

-(void) registerForNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivesUserLogInNotification:) name:TDWatchrUserDidLogInNotification object:nil];

}

-(void) receivesUserLogInNotification:(id) sender{
	NSData * userInformationData = [[NSUserDefaults standardUserDefaults ] objectForKey:TDWatchrLoggedInUserInformationKey];
	NSError * JSONParsingError = nil;
	id JSONObject = [NSJSONSerialization
					 JSONObjectWithData:userInformationData
					 options:NSJSONReadingMutableContainers
					 error:&JSONParsingError];
	
	if (JSONParsingError !=nil) {
		NSLog(@"Error retrieving user information");
	}else{
		_userInformation = [[JSONObject objectForKey:@"data"] copy];
		NSLog(@"_userInfor = %@", _userInformation);
		[_sideMenuTableView reloadData];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:YES];
	
	for (int i=0; i<_menuEntries.count; i++) {
		_selectedRow[i]=0;
	}
	_selectedRow[indexPath.row] = 1;

	
	[tableView reloadData];
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 60;
}


#pragma mark - UITableViewDataSource Methods

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	TDProfileHeaderView * profileHeader = (TDProfileHeaderView*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"profileHeader"];
	profileHeader.delegate =self;
	
	profileHeader.circleView.layer.cornerRadius = 25;
	profileHeader.circleView.layer.masksToBounds = YES;
	
	profileHeader.profileImageView.layer.cornerRadius = 22;
	profileHeader.profileImageView.layer.masksToBounds = YES;
	
	if (_userInformation) {
		[profileHeader.profileImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", TDAPIBaseURL,[[_userInformation objectForKey:@"profile_photo"] objectForKey:@"location"] ]] placeholderImage:[UIImage imageNamed:@"profile-photo-placeholder.png"]];
		profileHeader.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", [_userInformation objectForKey:@"first_name"], [_userInformation objectForKey:@"last_name"]];
	}

	
	return profileHeader;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
	
    return view;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
	
	cell.textLabel.text = [[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"name"];
	
	if (_selectedRow[indexPath.row] == 1) {
		cell.imageView.image = [UIImage imageNamed:[[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"selectedIcon"]];
	}else{
		cell.imageView.image = [UIImage imageNamed:[[_menuEntries objectAtIndex:indexPath.row] objectForKey:@"deselectedIcon"]];
	}
	
	return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _menuEntries.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

#pragma mark - TDProfileHeaderViewDelegate methods

-(void) profileHeader:(TDProfileHeaderView *)headerView profilePhotoTapped:(UIImageView *)profilePhoto{
	UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log out" otherButtonTitles: nil];
	[action showInView:rootVC.view];
}

-(void) profileHeader:(TDProfileHeaderView *)headerView usernameTapped:(UILabel *)usernameLabel{
	NSLog(@"label tapped");	
}

#pragma mark - UIActionSeheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex==0) {
		//Log out
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:TDWatchrAPIAccountIdentifier];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:TDWatchrLoggedInUserInformationKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		for (NXOAuth2Account * account in [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"watchrAPI"]) {
			[[NXOAuth2AccountStore sharedStore] removeAccount:account];
		}
		[[TDWelcomeScreenViewController sharedWelcomeScreen] presentWelcomeScreen:self animated:YES];
	}
}

@end
