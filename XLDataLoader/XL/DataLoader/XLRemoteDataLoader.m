//
//  XLRemoteDataLoader.m
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

#import <AFNetworking/AFNetworking.h>

#import "XLRemoteDataLoader.h"

@interface XLRemoteDataLoader()
{
    AFHTTPRequestOperation * _task;
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
    if (self){
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

-(AFHTTPRequestOperation *)prepareURLSessionTask
{
    NSMutableURLRequest * request = self.prepareURLRequest;
    AFHTTPRequestOperation *op = [(AFHTTPRequestOperation *)[AFJSONRequestOperation alloc] initWithRequest:request];
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
    NSMutableURLRequest * urlRequest = [[self sessionManager] requestWithMethod:@"GET"
                                                                         path:[self URLString]
                                                                   parameters:nil];
    return urlRequest;
}


-(NSString *)URLString
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must overrite sessionManager method of %@.", NSStringFromClass([self class])] userInfo:nil];
}

-(NSDictionary *)parameters
{
    return nil;
}

-(AFHTTPClient *)sessionManager;
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
