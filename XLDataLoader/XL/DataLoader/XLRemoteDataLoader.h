//
//  XLRemoteDataLoader.h
//  XLKit
//
//  Created by Martin Barreto on 6/26/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "XLDataLoader.h"

@protocol XLRemoteDataLoaderDelegate <XLDataLoaderDelegate>

@end

@interface XLRemoteDataLoader : XLDataLoader
{
    BOOL _isLoadingMore;
    BOOL _hasMoreToLoad;
    NSUInteger _offset;
    NSUInteger _limit;
    NSDictionary * _data;
    NSString * _searchString;
}

@property (weak) id<XLRemoteDataLoaderDelegate> delegate;
@property (readonly) BOOL isLoadingMore;
@property (readonly) BOOL hasMoreToLoad;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, readonly) NSString * searchString;

// designated initializer
-(id)initWithAFHTTPRequestOperationClass:(Class)class;

// call this method to force reload of data with the current offset limit values
-(void)forceReload;

-(void)loadMoreForIndex:(NSUInteger)index;

//////////////////////////////////////////////////////////////////////////////////////////

// You must override this method
-(NSMutableURLRequest *)prepareURLRequest;

// You must override this method.
-(AFHTTPClient *)AFHTTPClient;

//////////////////////////////////////////////////////////////////////////////////////////

// method called after a successful data load, if overrited by subclass don't forget to call super method (delegate is called from there).
-(void)successulDataLoad;
// method called after a failure on data load, if overrited by subclass don't forget to call super method (delegate is called from there).
-(void)unsuccessulDataLoadWithError:(NSError *)error;

// call for obtain the related fetched
-(NSDictionary *)fetchedData;

// invoqued when searchBar changes and view controller make use of searchTableViewController
-(void)changeSearchString:(NSString *)searchString;


@end
