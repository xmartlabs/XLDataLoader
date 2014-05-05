//
//  User+Additions.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/10/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "User+Additions.h"
#import "AppDelegate+Additions.h"
#import "NSObject+Additions.h"
#import "NSManagedObject+Additions.h"
#import "NSString+Additions.h"

#define USER_ID                        @"id"
#define USER_IMAGE_URL                 @"imageURL"
#define USER_NAME                      @"name"


@implementation User (Additions)

+ (User *)createOrUpdateWithServiceResult:(NSDictionary *)data inContext:(NSManagedObjectContext *)context;
{
    User *user = [User findFirstByAttribute:@"userId" withValue:[data[USER_ID] valueOrNil] inContext:context];
    if (!user)
    {
        user = [User insert:context];
    }
    user.userId = [data[USER_ID] valueOrNil];
    user.userImageURL = [data[USER_IMAGE_URL] valueOrNil];
    user.userName = [data[USER_NAME] valueOrNil];
    return user;
}

+ (UIImage *)defaultProfileImage
{
    return [UIImage imageNamed:@"default-avatar"];
}

+ (NSPredicate *)getPredicateBySearchInput:(NSString *)search {

    if (![NSString stringIsNilOrEmpty:search]) {
        return [NSPredicate predicateWithFormat:@"userName CONTAINS[cd] %@" , search];
    }
    return nil;
}

+ (NSFetchRequest *)getFetchRequest {
    return [User getFetchRequestBySearchInput:nil];
}

+ (NSFetchRequest *)getFetchRequestBySearchInput:(NSString *)search {
    NSFetchRequest * fetchRequest = [User fetchRequest];
    fetchRequest.predicate = [User getPredicateBySearchInput:search];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userName" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
    return fetchRequest;
}

@end
