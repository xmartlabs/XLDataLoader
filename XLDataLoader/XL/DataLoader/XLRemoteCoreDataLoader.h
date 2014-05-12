//
//  XLRemoteCoreDataLoader.h
//  XLDataLoader
//
//  Created by Martin Barreto on 4/24/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"

@interface XLRemoteCoreDataLoader : XLRemoteDataLoader

-(id)initWithCoreDataProviderClass:(Class<XLRemoteDataLoaderCoreDataProviderProtocol>)class;
-(id)initWithCoreDataProviderClass:(Class<XLRemoteDataLoaderCoreDataProviderProtocol>)class tag:(NSString *)tag;
@end
