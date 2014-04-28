//
//  XLRemoteCoreDataLoader.m
//  XLDataLoader
//
//  Created by Martin Barreto on 4/24/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLRemoteCoreDataLoader.h"
#import <CoreData/CoreData.h>

@interface XLRemoteCoreDataLoader()

@property Class<XLRemoteDataLoaderCoreDataProviderProtocol> coreDataProviderClass;

@end

@implementation XLRemoteCoreDataLoader

@synthesize filters = _filters;

-(id)initWithCoreDataProviderClass:(Class<XLRemoteDataLoaderCoreDataProviderProtocol>)coreDataProviderClass
{
    self = [super init];
    if (self){
        _coreDataProviderClass = coreDataProviderClass;
    }
    return self;
}

-(NSString *)URLString
{
    return [self.coreDataProviderClass remoteDataLoaderURLString:self];
}

-(NSDictionary *)parameters
{
    return [self.coreDataProviderClass remoteDataLoaderParameters:self];
}

-(void)successulDataLoad
{
    [super successulDataLoad];
    NSString * collectionValuePath = [self.coreDataProviderClass remoteDataLoaderCollectionKeyPath:self];
    NSArray * itemsArray = (collectionValuePath && ![collectionValuePath isEqualToString:@""]) ? [self.fetchedData valueForKeyPath:collectionValuePath] : self.fetchedData[kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse];
    _hasMoreToLoad = !((itemsArray.count == 0) || (itemsArray.count < _limit && itemsArray.count != 0));
    [self.coreDataProviderClass remoteDataLoaderCreateOrUpdateObjects:self];
}

-(NSMutableDictionary *)filters
{
    if (_filters) return _filters;
    _filters = [NSMutableDictionary dictionary];
    return _filters;
}



@end
