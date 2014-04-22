//
//  NSManagedObject+Additions.m
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)


+(instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value inContext:(NSManagedObjectContext *)context
{
    NSString * predicateStr = [NSString stringWithFormat:@"%@ = %%@", attribute];
    NSPredicate * searchByAttValue = [NSPredicate predicateWithFormat:predicateStr argumentArray:@[value]];
    NSFetchRequest * fetchRequest = [self fetchRequest];
    fetchRequest.predicate = searchByAttValue;
    fetchRequest.fetchLimit = 1;
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    return [result lastObject];
}

+(NSFetchRequest*)fetchRequest
{
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
}

+(NSEntityDescription*)entityDescriptor:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+(instancetype)insert:(NSManagedObjectContext *)context
{
    return [[NSManagedObject alloc] initWithEntity:[self entityDescriptor:context] insertIntoManagedObjectContext:context];
}

@end
