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
    [self.coreDataProviderClass remoteDataLoaderCreateOrUpdateObjects:self];
}

-(NSMutableDictionary *)filters
{
    if (_filters) return _filters;
    _filters = [NSMutableDictionary dictionary];
    return _filters;
}

-(NSString *)collectionKeyPath
{
    return [self.coreDataProviderClass remoteDataLoaderCollectionKeyPath:self];
}



@end
