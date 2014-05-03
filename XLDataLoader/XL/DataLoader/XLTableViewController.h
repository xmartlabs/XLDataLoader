//
//  XLStoryBoardTableViewController.h
//  XLDataLoader
//
//  Created by Martin Barreto on 4/24/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"
#import "XLLocalDataLoader.h"
#import "XLSearchBar.h"
#import "XLLoadingMoreView.h"
#import <UIKit/UIKit.h>

@interface XLTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UISearchBar * searchBar;

@property (nonatomic) XLRemoteDataLoader * remoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * localDataLoader;

@property (nonatomic) XLRemoteDataLoader * searchRemoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * searchLocalDataLoader;

@property (nonatomic) UIRefreshControl * refreshControl;

@property (nonatomic) UIView * backgroundViewForEmptyTableView;

@property BOOL supportRefreshControl; // default YES
@property BOOL loadingPagingEnabled;  // default YES
@property BOOL showNetworkReachability; //Default YES
@property BOOL supportSearchController; // default NO
@property BOOL fetchFromRemoteDataLoaderOnlyOnce; // Default YES
@property UITableViewStyle tableViewStyle; //Default UITableViewStylePlain, only used on non-storyboard controller

// The loader notifies the controller using these methods. override it from your concrete class.

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataSource;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataSource withError:(NSError *)error;


// overrite to be notified about change on table rows
-(void)didChangeGridContent;

-(void)didChangeSearchGridContent;

-(BOOL)tableIsEmpty;


@end
