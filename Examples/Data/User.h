//
//  User.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/15/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userImageURL;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *posts;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
