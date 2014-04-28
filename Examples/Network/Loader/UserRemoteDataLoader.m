//
//  UserRemoteDataLoader.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/16/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "UserRemoteDataLoader.h"
#import "HTTPSessionManager.h"
#import "AppDelegate+Additions.h"
#import "User+Additions.h"

#import "NSError+Additions.h"
#import "NSObject+Additions.h"

#define USER_TAG @"user"

@implementation UserRemoteDataLoader

-(NSString *)URLString
{
    return @"/mobile/users.json";
}

-(NSDictionary *)parameters
{
    NSString *filterParam = self.searchString ?: @"";
    return @{@"filter" : filterParam,
             @"offset" : @(self.offset),
             @"limit"  : @(self.limit)};
}

-(AFHTTPSessionManager *)sessionManager
{
    return [HTTPSessionManager sharedClient];
}

-(void)successulDataLoad {
    // change flags
    // [self fetchedData] contains the data coming from the server
    NSArray * itemsArray = [[self fetchedData] objectForKey:kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse];

    // This flag indicates if there is more data to load
    _hasMoreToLoad = !((itemsArray.count == 0) || (itemsArray.count < _limit && itemsArray.count != 0));
    [[AppDelegate managedObjectContext] performBlockAndWait:^{
        for (NSDictionary *item in itemsArray) {
            // Creates or updates the User and the user who created it with the data that came from the server
            [User createOrUpdateWithServiceResult:item[USER_TAG] saveContext:NO];
        }
        [self removeOutdatedData:itemsArray];
        [AppDelegate saveContext];
    }];
    
    // call super
    [super successulDataLoad];
}


#pragma mark - Auxiliary Functions

- (void)removeOutdatedData:(NSArray *)data
{
    // First, remove older data
    NSFetchRequest * fetchRequest = [User getFetchRequestBySearchInput:self.searchString];

    fetchRequest.fetchLimit = self.limit;
    fetchRequest.fetchOffset = self.offset;
    
    NSError *error;
    NSArray * oldObjects = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    NSArray * arrayToIterate = [oldObjects copy];
    
    if (error) {
        [error showAlertView];
        return;
    }
    
    for (User *user in arrayToIterate)
    {
        NSArray *filteredArray = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user.id = %@" argumentArray:@[user.userId]]];
        if (filteredArray.count == 0) {
            // This User no longer exists
            [[AppDelegate managedObjectContext] deleteObject:user];
        }
    }
}

@end
