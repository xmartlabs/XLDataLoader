//
//  AppDelegate+Additions.m
//  XLTableViewControllerTest
//
//  Created by Gaston Borba on 3/6/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "AppDelegate+Additions.h"

@implementation AppDelegate (Additions)

+(NSManagedObjectContext *)managedObjectContext
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+(void)saveContext
{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

+(NSDate *)dateFromString:(NSString *)dateString
{
    // date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    // hot fix from date
    NSRange range = [dateString rangeOfString:@"."];
    if (range.location != NSNotFound){
        dateString = [dateString substringToIndex:range.location];
    }
    return [formatter dateFromString:dateString];
}

@end
