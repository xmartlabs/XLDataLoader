//
//  XLTableWithFixedSearchViewController.h
//  XLDataLoader
//
//  Created by Martin Barreto on 2/6/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"
#import "XLLocalDataLoader.h"

#import <UIKit/UIKit.h>

@interface XLTableWithFixedSearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>


@property (weak, nonatomic) UITableView * tableView;

@property (nonatomic) XLRemoteDataLoader * remoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * localDataLoader;

@property (nonatomic) XLRemoteDataLoader * searchRemoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * searchLocalDataLoader;



@property (nonatomic) UIView * backgroundViewForEmptyTableView;


@property BOOL supportRefreshControl; // default YES
@property BOOL loadingPagingEnabled;  // default YES
@property BOOL showNetworkReachability; //Default YES

// The loader notifies the controller using these methods. override it from your concrete class.

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataSource;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataSource withError:(NSError *)error;


// overrite to be notified about change on table rows
-(void)didChangeGridContent;

-(void)didChangeSearchGridContent;

-(BOOL)tableIsEmpty;

@end
