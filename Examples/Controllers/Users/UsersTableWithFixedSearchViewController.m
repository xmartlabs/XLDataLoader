//
//  UsersTableWithFixedSearchViewController.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/16/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UsersTableWithFixedSearchViewController.h"
#import "UserLocalDataLoader.h"
#import "UserRemoteDataLoader.h"
#import "EmptyCollectionView.h"
#import "Constants.h"
#import "UserCell.h"
#import "User+Additions.h"
#import "UIColor+Additions.h"


// AFNetworking
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface UsersTableWithFixedSearchViewController ()

@end

@implementation UsersTableWithFixedSearchViewController

static NSString *const kCellIdentifier = @"CellIdentifier";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];

    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];

}

-(void)initialize
{
    self.loadingPagingEnabled = YES;
    
    // initializeDataLoaders
    [self setLocalDataLoader:[[UserLocalDataLoader alloc] init]];
    [self setRemoteDataLoader:[[UserRemoteDataLoader alloc] init]];
    // Search
    [self setSearchLocalDataLoader:[[UserLocalDataLoader alloc] init]];
    [self setSearchRemoteDataLoader:[[UserRemoteDataLoader alloc] init]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // register cells
    [self.searchDisplayController.searchResultsTableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:kCellIdentifier];
    
    [self customizeAppearance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)customizeAppearance
{
    [[self navigationItem] setTitle:@"Users - Fixed Search Bar"];
    
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

//- (void)viewDidLayoutSubviews {
//    // Overrides the superclass method
//    [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + self.topLayoutGuide.length + 44, self.view.bounds.size.width, self.view.bounds.size.height - self.topLayoutGuide.length - 44)];
//    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsZero];
//}


@end
