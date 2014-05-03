//
//  PersonLocalDataLoader.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "PostLocalDataLoader.h"
#import "Post+Additions.h"
#import "XLDataLoaderCoreDataStore.h"

@implementation PostLocalDataLoader

- (id)init {
    self = [super init];
    if (self) {

        // Post Fetch Request
        NSFetchRequest * fetchRequest = [Post getFetchRequest];
        NSFetchedResultsController * fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                 managedObjectContext:[XLDataLoaderCoreDataStore mainQueueContext]
                                                                                                   sectionNameKeyPath:nil
                                                                                                            cacheName:nil];
        [self setFetchedResultsController:fetchResultController];

    }
    return self;
}

@end
