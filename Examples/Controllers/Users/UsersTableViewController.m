//
//  UsersTableViewController.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/16/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UsersTableViewController.h"
#import "UserLocalDataLoader.h"
#import "UserRemoteDataLoader.h"
#import "EmptyCollectionView.h"
#import "Constants.h"
#import "User+Additions.h"
#import "UserCell.h"
#import "UIColor+Additions.h"

// AFNetworking
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface UsersTableViewController ()

@end

@implementation UsersTableViewController

static NSString *const kCellIdentifier = @"CellIdentifier";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Enable the pagination
        self.loadingPagingEnabled = YES;
        
        // Support Search Controller
        self.supportSearchController = YES;
        
        // Initialize Data Loaders
        [self initializeDataLoaders];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // SearchBar
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;

    // register cells
    [self.searchDisplayController.searchResultsTableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier];
    
    [self customizeAppearance];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = (UserCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];;

    User * user = nil;
    if (tableView == self.tableView){
        user = (User *)[self.localDataLoader objectAtIndexPath:indexPath];
    }
    else{
        user = (User *)[self.searchLocalDataLoader objectAtIndexPath:indexPath];
    }
    
    cell.userName.text = user.userName;
    NSMutableURLRequest* imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:user.userImageURL]];
    [imageRequest setValue:@"image/*" forHTTPHeaderField:@"Accept"];
    __typeof__(cell) __weak weakCell = cell;
    [cell.userImage setImageWithURLRequest: imageRequest
                          placeholderImage:[User defaultProfileImage]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       if (image) {
                                           [weakCell.userImage setImage:image];
                                       }
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                   }];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0f;
}


#pragma mark - Helpers

-(void)initializeDataLoaders
{
    [self setLocalDataLoader:[[UserLocalDataLoader alloc] init]];
    [self setRemoteDataLoader:[[UserRemoteDataLoader alloc] init]];
    
    // Search
    [self setSearchLocalDataLoader:[[UserLocalDataLoader alloc] init]];
    [self setSearchRemoteDataLoader:[[UserRemoteDataLoader alloc] init]];
}

-(void)customizeAppearance
{
    [[self navigationItem] setTitle:@"Users"];
    
    [self setBackgroundViewForEmptyTableView:[self emptyCollectionView]];
    
    [self.tableView setBackgroundColor:[UIColor colorWithHex:__COLOR_GRAY_VERY_LIGHT]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithHex:__COLOR_GRAY_VERY_LIGHT]];
    [self.searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsZero];
}

- (EmptyCollectionView *)emptyCollectionView
{
    EmptyCollectionView * emptyCollectionView = [[EmptyCollectionView alloc] init];
    emptyCollectionView.textLabel.text = @"Empty";
    return emptyCollectionView;
}

@end
