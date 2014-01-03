//
//  XLRemoteDataLoader.m
//  XLKit
//
//  Created by Martin Barreto on 6/26/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"
#import "AFNetworking.h"

@interface XLRemoteDataLoader()
{
    NSURLSessionDataTask * _task;
}

@property NSUInteger expiryTimeInterval;

@end


@implementation XLRemoteDataLoader

@synthesize delegate = _delegate;

// configutration properties
@synthesize expiryTimeInterval = _expiryTimeInterval;

// page paroperties
@synthesize offset = _offset;
@synthesize limit = _limit;

// searchString
@synthesize searchString = _searchString;

// state properties
@synthesize isLoadingMore = _isLoadingMore;

@synthesize hasMoreToLoad = _hasMoreToLoad;

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setDefaultValues];
    }
    return self;
}


-(void)setDefaultValues
{
    _task = nil;
    _offset = 0;
    _limit = 20;
    _data = nil;
    _isLoadingMore = NO;
    _hasMoreToLoad = YES;
}

-(void)setData:(NSDictionary *)data
{
    _data = data;
}

-(NSURLSessionDataTask *)prepareURLSessionTask
{
    NSMutableURLRequest * request = self.prepareURLRequest;
    XLRemoteDataLoader * __weak weakSelf = self;
    return [[self sessionManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [weakSelf unsuccessulDataLoadWithError:error];
        } else {
            [weakSelf setData:(NSDictionary *)responseObject];
            [weakSelf successulDataLoad];
        }
    }];
}

-(NSMutableURLRequest *)prepareURLRequest
{
    return [[self sessionManager].requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:[self URLString] relativeToURL:[[self sessionManager] baseURL]] absoluteString] parameters:[self parameters]];
}


-(NSString *)URLString
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must overrite sessionManager method of %@.", NSStringFromClass([self class])] userInfo:nil];
}

-(NSDictionary *)parameters
{
    return nil;
}

-(AFHTTPSessionManager *)sessionManager;
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must overrite sessionManager method of %@.", NSStringFromClass([self class])] userInfo:nil];
}


-(void)successulDataLoad
{
    _isLoadingMore = NO;
    // notify via delegate
    if (self.delegate){
        [self.delegate dataLoaderDidLoadData:self];
    }
}

-(void)unsuccessulDataLoadWithError:(NSError *)error
{
    // change flags
    _isLoadingMore = NO;
    
    // notify via delegate
    if (self.delegate){
        [self.delegate dataLoaderDidFailLoadData:self withError:error];
    }
}

-(void)loadMoreForIndex:(NSUInteger)index
{
    if (!_isLoadingMore)
    {
        _offset = index;
        [self load];
    }
}

-(void)load
{
    if (!_isLoadingMore)
    {
        _isLoadingMore = YES;
        _task = [self prepareURLSessionTask];
        [_task resume];
        if (self.delegate){
            [self.delegate dataLoaderDidStartLoadingData:self];
        }
    }
}


-(void)forceReload
{
    if (_task){
        [_task cancel];
        _task = nil;
    }
    [self setDefaultValues];
    [self load];
}

-(NSDictionary *)fetchedData
{
    return _data;
}

// invoqued when searchBar changes and view controller make use of searchTableViewController
-(void)changeSearchString:(NSString *)searchString
{
    _searchString = searchString;
    [self forceReload];
}




@end
