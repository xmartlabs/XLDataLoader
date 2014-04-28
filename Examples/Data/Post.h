//
//  Post.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 4/15/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSString * postText;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) User *user;

@end
