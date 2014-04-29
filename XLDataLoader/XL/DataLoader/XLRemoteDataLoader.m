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


NSString * const kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse = @"data";

#import <AFNetworking/AFNetworking.h>
#import "XLRemoteDataLoader.h"

@interface XLRemoteDataLoader()
{
    NSURLSessionDataTask * _task;
}

@property NSUInteger expiryTimeInterval;

@end


@implementation XLRemoteDataLoader

@synthesize tag = _tag;
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

-(id)initWithTag:(NSString *)tag
{
    self = [self init];
    if (self){
        _tag = tag;
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
            if (responseObject){
                NSMutableDictionary * newUserInfo = [error.userInfo mutableCopy];
                [newUserInfo setObject:responseObject forKey:AFNetworkingTaskDidCompleteSerializedResponseKey];
                NSError * newError = [NSError errorWithDomain:error.domain code:error.code userInfo:newUserInfo];
                [weakSelf unsuccessulDataLoadWithError:newError];
            }
            else{
                [weakSelf unsuccessulDataLoadWithError:error];
            }
        } else {
            [responseObject isKindOfClass:[NSDictionary class]] ? [weakSelf setData:(NSDictionary *)responseObject] : [weakSelf setData:@{kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse : responseObject}];
            [weakSelf successulDataLoad];
            // notify via delegate
            if (weakSelf.delegate){
                [weakSelf.delegate dataLoaderDidLoadData:self];
            }
        }
    }];
}

-(NSMutableURLRequest *)prepareURLRequest
{
    NSError * error;
    return [[self sessionManager].requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:[self URLString] relativeToURL:[[self sessionManager] baseURL]] absoluteString] parameters:[self parameters] error:&error];
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
    if (!_isLoadingMore){
        _offset = index;
        [self load];
    }
}

-(void)load
{
    if (!_isLoadingMore){
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

-(NSString *)collectionKeyPath
{
    return _collectionKeyPath;
}





@end
