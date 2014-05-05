//
//  User+Additions.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/10/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "User.h"

@interface User (Additions)

+ (User *)createOrUpdateWithServiceResult:(NSDictionary *)data inContext:(NSManagedObjectContext *)context;

+ (UIImage *)defaultProfileImage;

+ (NSPredicate *)getPredicateBySearchInput:(NSString *)search;

+ (NSFetchRequest *)getFetchRequest;

+ (NSFetchRequest *)getFetchRequestBySearchInput:(NSString *)search;

@end
