//
//  TableViewController.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "PostsTableViewController.h"
#import "PostLocalDataLoader.h"
#import "PostRemoteDataLoader.h"
#import "EmptyCollectionView.h"
#import "PostCell.h"
#import "Constants.h"
#import "Post+Additions.h"
#import "User+Additions.h"
#import "UIColor+Additions.h"

// AFNetworking
#import <AFNetworking/UIImageView+AFNetworking.h>


#define SECONDS_IN_A_MINUTE 60
#define SECONDS_IN_A_HOUR  3600
#define SECONDS_IN_A_DAY 86400
#define SECONDS_IN_A_MONTH_OF_30_DAYS 2592000
#define SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS 31104000

@interface PostsTableViewController ()

@property PostCell *offScreenCell;

@end

@implementation PostsTableViewController

@synthesize offScreenCell = _offScreenCell;

static NSString *const kCellIdentifier = @"CellIdentifier";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Enable the pagination
        self.loadingPagingEnabled = YES;
        
        // Initialize Data Loaders
        [self initializeDataLoaders];
    }
    return self;
}

-(void)initializeDataLoaders {
    [self setLocalDataLoader:[[PostLocalDataLoader alloc] init]];
    [self setRemoteDataLoader:[[PostRemoteDataLoader alloc] init]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // register cells
    [self.tableView registerClass:[PostCell class] forCellReuseIdentifier:kCellIdentifier];
    
    [self setBackgroundViewForEmptyTableView:[self emptyCollectionView]];
    
    [[self navigationItem] setTitle:@"Posts"];
    [self customizeAppearance];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Post * post = (Post *)[self.localDataLoader objectAtIndexPath:indexPath];
    User * user = post.user;
    
    cell.userName.text = user.userName;
    cell.postDate.text = [self timeAgo:post.postDate];
    cell.postText.text = post.postText;
    
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
    if (!self.offScreenCell)
    {
        self.offScreenCell = (PostCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        // Dummy Data
        self.offScreenCell.userName.text = @"offscreen name";
        self.offScreenCell.postDate.text = @"7m";
        [self.offScreenCell.userImage setImage:[User defaultProfileImage]];
    }
    
    Post * post = (Post *)[self.localDataLoader objectAtIndexPath:indexPath];
    
    self.offScreenCell.postText.text = post.postText;
    
    [self.offScreenCell.contentView setNeedsLayout];
    [self.offScreenCell.contentView layoutIfNeeded];
    CGSize size = [self.offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

#pragma mark - Helpers

- (EmptyCollectionView *)emptyCollectionView
{
    EmptyCollectionView * emptyCollectionView = [[EmptyCollectionView alloc] init];
    emptyCollectionView.textLabel.text = @"Empty";
    return emptyCollectionView;
}


- (NSString *)timeAgo:(NSDate *)date {
   NSTimeInterval distanceBetweenDates = [date timeIntervalSinceDate:[NSDate date]] * (-1);
    int distance = (int)floorf(distanceBetweenDates);
    if (distance <= 0) {
        return @"now";
    }
    else if (distance < SECONDS_IN_A_MINUTE) {
        return   [NSString stringWithFormat:@"%ds", distance];
    }
    else if (distance < SECONDS_IN_A_HOUR) {
        distance = distance / SECONDS_IN_A_MINUTE;
        return   [NSString stringWithFormat:@"%dm", distance];
    }
    else if (distance < SECONDS_IN_A_DAY) {
        distance = distance / SECONDS_IN_A_HOUR;
        return   [NSString stringWithFormat:@"%dh", distance];
    }
    else if (distance < SECONDS_IN_A_MONTH_OF_30_DAYS) {
        distance = distance / SECONDS_IN_A_DAY;
        return   [NSString stringWithFormat:@"%dd", distance];
    }
    else if (distance < SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS) {
        distance = distance / SECONDS_IN_A_MONTH_OF_30_DAYS;
        return   [NSString stringWithFormat:@"%dmo", distance];
    } else {
        distance = distance / SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS;
        return   [NSString stringWithFormat:@"%dy", distance];
    }
}

-(void)customizeAppearance
{
    [self.tableView setBackgroundColor:[UIColor colorWithHex:__COLOR_GRAY_VERY_LIGHT]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.offScreenCell = nil;
    [self.tableView reloadData];
}

@end
