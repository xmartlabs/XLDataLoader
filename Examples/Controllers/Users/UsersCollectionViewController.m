//
//  UsersCollectionViewController.m
//  XLDataLoader
//
//  Created by Martin Barreto on 5/4/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "UserLocalDataLoader.h"
#import "UserRemoteDataLoader.h"
#import "EmptyCollectionView.h"
#import "Constants.h"
#import "User+Additions.h"
#import "UserCollectionCell.h"
#import "UserCell.h"

#import "UsersCollectionViewController.h"

@interface UsersCollectionViewController ()

@end

@implementation UsersCollectionViewController

static NSString *const kCellIdentifier = @"CellIdentifier";

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self  = [super initWithCollectionViewLayout:layout];
    if (self){
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
    // Enable the pagination
    self.loadingPagingEnabled = YES;
    
    // Support Search Controller
    self.supportSearchController = YES;
    
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
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
