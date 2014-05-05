//
//  Post+Additions.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/10/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "Post+Additions.h"
#import "AppDelegate+Additions.h"
#import "User+Additions.h"
#import "NSManagedObject+Additions.h"
#import "NSObject+Additions.h"

#define POST_ID     @"id"
#define POST_TEXT   @"text"
#define POST_DATE   @"created_at"
#define POST_USER   @"user"

@implementation Post (Additions)

+ (Post *)createOrUpdateWithServiceResult:(NSDictionary *)data inContext:(NSManagedObjectContext *)context;
{
    Post * post = [Post findFirstByAttribute:@"postId" withValue:[data[POST_ID] valueOrNil] inContext:context];
    if (!post)
    {
        post = [Post insert:context];
    }
    post.postId   = [data[POST_ID] valueOrNil];
    post.postText = [data[POST_TEXT] valueOrNil];
    post.postDate = [AppDelegate dateFromString:[data[POST_DATE] valueOrNil]];
    
    post.user = [User createOrUpdateWithServiceResult:data[POST_USER] inContext:context];    
    return post;
}

+ (NSFetchRequest *)getFetchRequest
{
    NSFetchRequest * fetchRequest = [Post fetchRequest];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"postDate" ascending:NO]];
    return fetchRequest;
}

@end
