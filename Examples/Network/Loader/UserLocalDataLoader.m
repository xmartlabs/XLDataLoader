//
//  UserLocalDataLoader.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/16/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UserLocalDataLoader.h"
#import "User+Additions.h"
#import "XLDataLoaderCoreDataStore.h"

@implementation UserLocalDataLoader
{
    NSString *_searchString;
}

- (id)init {
    self = [super init];
    if (self) {
        
        NSFetchRequest * fetchRequest = [User getFetchRequest];
        NSFetchedResultsController * fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                 managedObjectContext:[XLDataLoaderCoreDataStore mainQueueContext]
                                                                                                   sectionNameKeyPath:nil
                                                                                                            cacheName:nil];
        [self setFetchedResultsController:fetchResultController];
        
    }
    return self;
}

-(void)changeSearchString:(NSString *)searchString
{
    _searchString = searchString;
    [self refreshPredicate];
}

- (void)refreshPredicate
{
    [self setPredicate:[User getPredicateBySearchInput:_searchString]];
}

@end
