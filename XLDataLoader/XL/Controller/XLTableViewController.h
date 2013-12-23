//
//  XLTableViewController.h
//  XLKit
//
//  Created by Martin Barreto on 7/25/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"
#import "XLLocalDataLoader.h"

@interface XLTableViewController : UITableViewController<UISearchDisplayDelegate>


@property (nonatomic) XLRemoteDataLoader * remoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * localDataLoader;

@property (nonatomic) XLRemoteDataLoader * searchRemoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * searchLocalDataLoader;

@property (nonatomic) UIView * backgroundViewForEmptyTableView;


@property BOOL supportRefreshControl; // default YES
@property BOOL loadingPagingEnabled;  // default YES
@property BOOL supportSearchController; // default NO

// The loader notifies the controller using these methods. override it from your concrete class.

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataSource;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataSource withError:(NSError *)error;


// overrite to be notified about change on table rows
-(void)didChangeGridContent;

-(void)didChangeSearchGridContent;

-(BOOL)tableIsEmpty;

@end
