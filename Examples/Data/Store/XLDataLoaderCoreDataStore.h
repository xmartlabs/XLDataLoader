//
//  XLDataLoaderCoreDataStore.h
//  XLDataLoader
//
//  Created by Martin Barreto on 4/29/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface XLDataLoaderCoreDataStore : NSObject

+(id)defaultStore;

+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;

+ (void)savePrivateQueueContext;
+ (void)saveMainQueueContext;

+ (NSManagedObjectID *)managedObjectIDFromString:(NSString *)managedObjectIDString;

@end
