//
//  XLLocalDataLoader.m
//  XLDataLoader ( https://github.com/xmartlabs/XLDataLoader )
//
//  Created by Martin Barreto on 10/25/13.
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLLocalDataLoader.h"
#import <CoreData/CoreData.h>


@interface XLLocalDataLoader() <NSFetchedResultsControllerDelegate>

// private properties
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation XLLocalDataLoader
{
    NSUInteger _offset;
    NSUInteger _limit;
}

// private properties
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize delegate                 = _delegate;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize trackDataUpdatesOfItems  = _trackDataUpdatesOfItems;


-(id)init
{
    return [self initWithLimit:20];
}

-(id)initWithLimit:(NSUInteger)limit
{
    self = [super init];
    if (self){
        _limit = limit;
        _trackDataUpdatesOfItems = NO;
        _offset = 0;
    }
    return self;
}


-(id<XLLocalDataLoaderDelegate>)delegate
{
    return _delegate;
}

-(void)setDelegate:(id<XLLocalDataLoaderDelegate>)delegate
{
    if (delegate){
        _delegate = delegate;
        _fetchedResultsController.delegate = self;
    }
    else{
        _fetchedResultsController.delegate = nil;
        _delegate = nil;
    }
}

-(void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController)
    {
        _fetchedResultsController = fetchedResultsController;
    }
}

-(void)setPredicate:(NSPredicate *)predicate
{
    if (_fetchedResultsController){
        [_fetchedResultsController.fetchRequest setPredicate:predicate];
    }
}


-(void)reload
{

}


-(void)forceReload:(BOOL)defaultValues
{
    if (defaultValues){
        _offset = 0;
    }
    [self.fetchedResultsController.fetchRequest setFetchLimit:(_offset + _limit)];
    [self.fetchedResultsController.fetchRequest setFetchOffset:0];
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]){
        [self.delegate dataLoaderDidLoadData:self];
    }
    else{
        [self.delegate dataLoaderDidFailLoadData:self withError:error];
    }
}

// get offset and limit
-(NSUInteger)offset
{
    return _offset;
}

-(NSUInteger)limit
{
    return _limit;
}

-(void)setLimit:(NSUInteger)limit
{
    _limit = limit;
}

// get core data object at index path
-(NSManagedObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [self numberOfRowsInSection:indexPath.section]){
        return [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    return nil;
}

-(NSIndexPath *)indexPathForObject:(id)object
{
    return [self.fetchedResultsController indexPathForObject:object];
}


-(void)changeOffsetTo:(NSUInteger)newOffset
{
    if (_offset != newOffset){
        _offset = newOffset;
        [_fetchedResultsController.fetchRequest setFetchLimit:(_offset + _limit)];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.delegate && !self.suspendAutomaticTrackingOfChangesInManagedObjectContext &&  [self.delegate respondsToSelector:@selector(localDataLoader:controllerWillChangeContent:)]){
        [self.delegate localDataLoader:self controllerWillChangeContent:controller];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.delegate && !self.suspendAutomaticTrackingOfChangesInManagedObjectContext){
        [self.delegate localDataLoader:self
                            controller:controller
                      didChangeSection:sectionInfo
                               atIndex:sectionIndex
                         forChangeType:type];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.delegate && !self.suspendAutomaticTrackingOfChangesInManagedObjectContext){
        if (type == NSFetchedResultsChangeInsert){
            [self.delegate localDataLoader:self controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
        else if (type == NSFetchedResultsChangeUpdate && self.trackDataUpdatesOfItems) {
            [self.delegate localDataLoader:self controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
        else if (type == NSFetchedResultsChangeDelete) {
            [self.delegate localDataLoader:self controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
        else if (type == NSFetchedResultsChangeMove)
        {
            [self.delegate localDataLoader:self controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
        }
        
        
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.delegate){
        [self.delegate localDataLoader:self controllerDidChangeContent:controller];
    }
}

-(NSArray *)sections
{
    return [self.fetchedResultsController sections];
}

-(NSUInteger)numberOfSections
{
    return [[self.fetchedResultsController sections] count];
}

-(NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex
{
    return [[[self.fetchedResultsController sections] objectAtIndex:sectionIndex] numberOfObjects];
}


-(NSIndexPath *)nextIndexPathIfExist:(NSIndexPath *)indexPath
{
    if ((indexPath.item + 1) < [self numberOfRowsInSection:indexPath.section])
    {
        return [NSIndexPath indexPathForItem:(indexPath.item + 1) inSection:indexPath.section];
    }
    if ((indexPath.section + 1) < [self numberOfSections])
    {
        return [NSIndexPath indexPathForItem:0 inSection:(indexPath.section + 1)];
    }
    return nil;
}

-(NSIndexPath *)previousIndexPathIfExist:(NSIndexPath *)indexPath
{
    if (indexPath.item  > 0)
    {
        return [NSIndexPath indexPathForItem:(indexPath.item - 1) inSection:indexPath.section];
    }
    if (indexPath.section > 0)
    {
        return [NSIndexPath indexPathForItem:([self numberOfRowsInSection:(indexPath.section - 1)] -1) inSection:(indexPath.section - 1)];
    }
    return nil;
}


-(NSUInteger)totalNumberOfObjects
{
    return [self.fetchedResultsController.managedObjectContext countForFetchRequest:self.fetchedResultsController.fetchRequest error:nil];
}

-(NSUInteger)absoluteIndexForObject:(id)object
{
    NSIndexPath * objectIndexPath = [self indexPathForObject:object];
    NSUInteger result = objectIndexPath.item;
    for (NSInteger i = 0; i < objectIndexPath.section; i++){
        result +=  [self numberOfRowsInSection:i];
    }
    return result;
}


-(void)changeSearchString:(NSString *)searchString
{
}






@end
