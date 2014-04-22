//
//  NSManagedObject+Additions.h
//  XLDataLoader Example
//
//  Created by Gaston Borba on 4/21/14.
//  Copyright (c) 2014 XmartLabs. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Additions)

+(instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)value inContext:(NSManagedObjectContext *)context;

+(NSFetchRequest*)fetchRequest;

+(instancetype)insert:(NSManagedObjectContext *)context;

@end
