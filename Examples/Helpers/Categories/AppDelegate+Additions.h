//
//  AppDelegate+Additions.h
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Additions)

+(NSManagedObjectContext *)managedObjectContext;
+(void)saveContext;
+(NSDate *)dateFromString:(NSString *)dateString;

@end
