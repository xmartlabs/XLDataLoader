//
//  XLCollectionViewController.h
//  XLKit
//
//  Created by Martin Barreto on 8/24/13.
//  Copyright (c) 2013 Xmartlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLRemoteDataLoader.h"
#import "XLLocalDataLoader.h"

@interface XLCollectionViewController : UICollectionViewController <XLRemoteDataLoaderDelegate, XLLocalDataLoaderDelegate>

@property (nonatomic) XLRemoteDataLoader * remoteDataLoader;
@property (nonatomic) XLLocalDataLoader  * localDataLoader;

@end
