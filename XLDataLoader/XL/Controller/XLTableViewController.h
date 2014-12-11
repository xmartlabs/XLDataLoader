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
#import <UIKit/UIKit.h>

@protocol XLTableViewControllerDelegate <NSObject>

@required
-(void)showError:(NSError*)error;
// overrite to be notified about change on table rows
-(void)didChangeGridContent;
-(void)didChangeSearchGridContent;

@end

@interface XLTableViewController : UIViewController<XLTableViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, XLDataLoaderDelegate>

@property IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UIView * networkStatusView;
@property (nonatomic) IBOutlet UISearchBar * searchBar;

@property (nonatomic) XLRemoteDataLoader * remoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * localDataLoader;

@property (nonatomic) XLRemoteDataLoader * searchRemoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * searchLocalDataLoader;

@property (readonly, nonatomic) UIRefreshControl * refreshControl;

@property (nonatomic) UIView * backgroundViewForEmptyTableView;

@property BOOL supportRefreshControl; // default YES
@property BOOL loadingPagingEnabled;  // default YES
@property BOOL showNetworkReachability; //Default YES
@property BOOL showNetworkConnectivityErrors; // Default YES
@property BOOL supportSearchController; // default NO
@property BOOL fetchFromRemoteDataLoaderOnlyOnce; // Default YES
@property UITableViewStyle tableViewStyle; //Default UITableViewStylePlain, only used on non-storyboard controller

-(BOOL)tableIsEmpty;


@end
