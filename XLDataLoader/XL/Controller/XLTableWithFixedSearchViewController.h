//
//  XLTableWithFixedSearchViewController.h
//  XLDataLoader ( https://github.com/xmartlabs/XLDataLoader )
//
//  Created by Martin Barreto on 10/25/13.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
@property BOOL fetchFromRemoteDataLoaderOnlyOnce; // Default YES

// The loader notifies the controller using these methods. override it from your concrete class.

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataSource;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataSource withError:(NSError *)error;


// overrite to be notified about change on table rows
-(void)didChangeGridContent;

-(void)didChangeSearchGridContent;

-(BOOL)tableIsEmpty;

@end
