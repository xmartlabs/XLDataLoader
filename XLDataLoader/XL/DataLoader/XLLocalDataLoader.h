//
//  XLLocalDataLoader.h
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

#import <Foundation/Foundation.h>
#import "XLDataLoader.h"

#import <CoreData/CoreData.h>


@class  XLLocalDataLoader;

@protocol XLLocalDataLoaderDelegate <XLDataLoaderDelegate>


/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
 controller - controller instance that noticed the change on its fetched objects
 anObject - changed object
 indexPath - indexPath of changed object (nil for inserts)
 type - indicates if the change was an insert, delete, move, or update
 newIndexPath - the destination path for inserted or moved objects, nil otherwise
 
 Changes are reported with the following heuristics:
 
 On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported.
 The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
 The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
 */
- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
 controller - controller instance that noticed the change on its sections
 sectionInfo - changed section
 index - index of changed section
 type - indicates if the change was an insert or delete
 
 Changes on section info are reported before changes on fetchedObjects.
 */
- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controllerWillChangeContent:(NSFetchedResultsController *)controller;

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */

@optional
- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controllerDidChangeContent:(NSFetchedResultsController *)controller;

/* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
 If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
 Only needed if a section index is used.
 */
@optional
- (NSString *)localDataLoader:(XLLocalDataLoader *)localDataLoader controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName;

@end


@interface XLLocalDataLoader : XLDataLoader

@property (weak) id<XLLocalDataLoaderDelegate> delegate;

@property BOOL trackDataUpdatesOfItems;

@property BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;


-(id)initWithLimit:(NSUInteger)limit;

-(void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

-(void)setPredicate:(NSPredicate *)predicate;

// invoqued when searchBar changes and view controller make use of searchTableViewController
-(void)changeSearchString:(NSString *)searchString;


// get offset and limit
-(NSUInteger)offset;
-(NSUInteger)limit;
-(void)setLimit:(NSUInteger)limit;

// get core data object at index path
-(NSManagedObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

-(NSIndexPath *)indexPathForObject:(id)object;

// call this method to force reload of data with the current offset limit values
-(void)forceReload;

//// get the number of items
//-(NSUInteger)dataCount;

// this method fetch the rest of the loaded data
-(void)changeOffsetTo:(NSUInteger)newOffset;

-(NSArray *)sections;

-(NSUInteger)numberOfSections;

-(NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex;

-(NSIndexPath *)previousIndexPathIfExist:(NSIndexPath *)indexPath;

-(NSIndexPath *)nextIndexPathIfExist:(NSIndexPath *)indexPath;

-(NSUInteger)totalNumberOfObjects;

-(NSUInteger)absoluteIndexForObject:(id)object;


@end
