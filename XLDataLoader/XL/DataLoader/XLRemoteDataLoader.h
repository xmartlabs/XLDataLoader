//
//  XLRemoteDataLoader.h
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

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "XLDataLoader.h"


NSString * const kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse;

@class XLRemoteDataLoader;

@protocol XLRemoteDataLoaderDelegate <XLDataLoaderDelegate>

@end

@protocol XLRemoteDataLoaderCoreDataProviderProtocol <NSObject>

@required
+(void)remoteDataLoaderCreateOrUpdateObjects:(XLRemoteDataLoader *)remoteDatLoader;
+(NSString *)remoteDataLoaderURLString:(XLRemoteDataLoader *)remoteDatLoader;
+(NSDictionary *)remoteDataLoaderParameters:(XLRemoteDataLoader *)remoteDatLoader;
+(NSString *)remoteDataLoaderCollectionKeyPath:(XLRemoteDataLoader *)remoteDataLoader;

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
@property (nonatomic, readonly) NSString * tag;
@property (weak) id<XLRemoteDataLoaderDelegate> delegate;
@property (readonly) BOOL isLoadingMore;
@property (readonly) BOOL hasMoreToLoad;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger limit;
@property (nonatomic, readonly) NSString * searchString;
@property (readonly) NSMutableDictionary * filters;
@property (nonatomic) NSString * collectionKeyPath;



-(id)init;

-(id)initWithTag:(NSString *)tag;

// call this method to force reload of data with the current offset limit values
-(void)forceReload:(BOOL)defaultValues;

-(void)loadMoreForIndex:(NSUInteger)index;

//////////////////////////////////////////////////////////////////////////////////////////

// You must override this method
-(NSString *)URLString;

// You must override this method
-(NSDictionary *)parameters;

// You must override this method.
-(AFHTTPSessionManager *)sessionManager;

-(NSMutableURLRequest *)prepareURLRequest;

//////////////////////////////////////////////////////////////////////////////////////////

// method called after a successful data load, if overwritten by a subclass don't forget to call super method (delegate is called from there).
-(void)successulDataLoad;
// method called after a failure on data load, if overwritten by a subclass don't forget to call super method (delegate is called from there).
-(void)unsuccessulDataLoadWithError:(NSError *)error;

// cancels the active request
-(void)cancelRequest;

// call to obtain the related fetched data
-(NSDictionary *)fetchedData;

// invoked when searchBar changes and view controller make use of searchTableViewController
-(void)changeSearchString:(NSString *)searchString;



@end
