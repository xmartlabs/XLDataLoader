//
//  Post+Additions.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/10/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "Post.h"

@interface Post (Additions)

+ (Post *)createOrUpdateWithServiceResult:(NSDictionary *)data inContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)getFetchRequest;

@end
