//
//  XLDataLoader.h
//  XLKit
//
//  Created by Martin Barreto on 7/26/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const XLDataLoaderErrorDomain;


@class XLDataLoader;

@protocol XLDataLoaderDelegate <NSObject>


-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;

-(void)dataLoaderDidLoadData:(XLDataLoader *)dataSource;

-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataSource withError:(NSError *)error;


@end




@interface XLDataLoader : NSObject

@end
