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
    AFHTTPRequestOperation * _operation;
}

@property NSUInteger expiryTimeInterval;
@property Class afRequestOperationclass;

-(AFHTTPRequestOperation *)prepareRequest;

@end


@implementation XLRemoteDataLoader

@synthesize delegate = _delegate;
@synthesize afRequestOperationclass = _afRequestOperationclass;

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

-(id)initWithAFHTTPRequestOperationClass:(Class)afRequestOperationclass
{
    if (![afRequestOperationclass isSubclassOfClass:[AFHTTPRequestOperation class]])
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ musb be subclass of AFHTTPRequestOperation", NSStringFromClass([AFHTTPRequestOperation class])] userInfo:nil];
    }
    self = [super init];
    if (self)
    {
        _afRequestOperationclass = afRequestOperationclass;
        [self setDefaultValues];
    }
    return self;
}


-(void)setDefaultValues
{
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

-(AFHTTPRequestOperation *)prepareRequest
{
    NSMutableURLRequest * urlRequest = self.prepareURLRequest;
    AFHTTPRequestOperation *op = [(AFHTTPRequestOperation *)[self.afRequestOperationclass alloc] initWithRequest:urlRequest];
    XLRemoteDataLoader * __weak weakSelf = self;
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf setData:(NSDictionary *)responseObject];
        [weakSelf successulDataLoad];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf unsuccessulDataLoadWithError:error];
    }];
    return op;
}

-(NSMutableURLRequest *)prepareURLRequest
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must overrite prepareURLRequest method of %@.", NSStringFromClass([self class])] userInfo:nil];
}

-(AFHTTPClient *)AFHTTPClient
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must overrite AFHTTPClient method of %@.", NSStringFromClass([self class])] userInfo:nil];
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
        _operation = [self prepareRequest];
        [[self AFHTTPClient] enqueueHTTPRequestOperation:_operation];
        if (self.delegate){
            [self.delegate dataLoaderDidStartLoadingData:self];
        }
    }
}


-(void)forceReload
{
    if (_operation){
        [_operation cancel];
        _operation = nil;
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
