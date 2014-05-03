//
//  XLCollectionViewController.m
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

#import  "UIScrollView+SVInfiniteScrolling.h"

#import "XLLoadingMoreView.h"
#import "XLNetworkStatusView.h"
#import "XLCollectionViewController.h"
#import "XLSearchBar.h"

@protocol FixSetSearchViewController <NSObject>

@optional

-(void)setSearchDisplayController:(UISearchDisplayController *)searchDisplayController;

@end

@interface XLCollectionViewController()
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    NSTimer * _searchDelayTimer;
}

@property UIRefreshControl * refreshControl;
@property BOOL beganUpdates;
@property BOOL searchBeganUpdates;
@property (nonatomic) XLLoadingMoreView * loadingMoreView;
@property (nonatomic) XLLoadingMoreView * searchLoadingMoreView;
@property (nonatomic) XLNetworkStatusView * networkStatusView;
@property (readonly) BOOL searchLoadingPagingEnabled;

@end


@implementation XLCollectionViewController

@synthesize loadingPagingEnabled = _loadingPagingEnabled;

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self){
        _searchDelayTimer = nil;
        self.remoteDataLoader = nil;
        self.localDataLoader  = nil;
        self.searchRemoteDataLoader = nil;
        self.searchLocalDataLoader = nil;
        self.supportRefreshControl = YES;
        self.loadingPagingEnabled = YES;
        self.supportSearchController = NO;
        self.showNetworkReachability = YES;
        self.fetchFromRemoteDataLoaderOnlyOnce = YES;
    }
    return self;
}

#pragma mark - Properties

-(XLLoadingMoreView *)loadingMoreView
{
    if (_loadingMoreView) return _loadingMoreView;
    _loadingMoreView = [[XLLoadingMoreView alloc] init];
    return _loadingMoreView;
}

-(XLLoadingMoreView *)searchLoadingMoreView
{
    if (_searchLoadingMoreView) return _searchLoadingMoreView;
    _searchLoadingMoreView = [[XLLoadingMoreView alloc] init];
    return _searchLoadingMoreView;
}

-(XLNetworkStatusView *)networkStatusView
{
    if (!_networkStatusView){
        _networkStatusView = [[XLNetworkStatusView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, 30)];
        _networkStatusView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _networkStatusView;
}

-(void)setLoadingPagingEnabled:(BOOL)loadingPagingEnabled
{
    _loadingPagingEnabled = loadingPagingEnabled;
}

-(BOOL)loadingPagingEnabled
{
    return _loadingPagingEnabled && self.remoteDataLoader;
}

-(BOOL)searchLoadingPagingEnabled
{
    return self.searchRemoteDataLoader != nil;
}


#pragma mark - methods

-(void)setRemoteDataLoader:(XLRemoteDataLoader *)remoteDataLoader
{
    _remoteDataLoader = remoteDataLoader;
    _remoteDataLoader.delegate = self;
}


-(void)setLocalDataLoader:(XLLocalDataLoader *)localDataLoader
{
    _localDataLoader = localDataLoader;
}


-(void)setSearchLocalDataLoader:(XLLocalDataLoader *)searchLocalDataLoader
{
    _searchLocalDataLoader = searchLocalDataLoader;
}


-(void)setSearchRemoteDataLoader:(XLRemoteDataLoader *)searchRemoteDataLoader
{
    _searchRemoteDataLoader = searchRemoteDataLoader;
    _searchRemoteDataLoader.delegate = self;
}

#pragma mark - UIViewController life cycle.

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objectChanges = [NSMutableArray new];
    _sectionChanges = [NSMutableArray new];
    if (self.loadingPagingEnabled == NO){
        [[self localDataLoader] setLimit:0];
    }
    [[self localDataLoader] forceReload];
    // initialize refresh Control
    if (self.supportRefreshControl){
        self.collectionView.alwaysBounceVertical = YES;
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:self.refreshControl];
    }
    if (self.loadingPagingEnabled){
        __typeof__(self) __weak weakSelf = self;
        [self.collectionView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf.remoteDataLoader.isLoadingMore){
                [weakSelf.collectionView.infiniteScrollingView startAnimating];
                [weakSelf.remoteDataLoader loadMoreForIndex:[weakSelf.localDataLoader totalNumberOfObjects]];
            }
        }];
    }
    if (self.supportSearchController)
    {
        // This should not be necessary, see the ref for self.searchDisplayController
        // self.searchDisplayController = displayController;
        // But self.searchDisplayController is never asigned (it`s always nil).
        // See this answer in StackOverflow: http://stackoverflow.com/a/17324921/1070393
        [self performSelector:@selector(setSearchDisplayController:) withObject:[self createDisplayController]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.localDataLoader.delegate = self;
    self.remoteDataLoader.delegate = self;
    [self.collectionView  reloadData];
    if (self.searchDisplayController.isActive){
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    if (!self.fetchFromRemoteDataLoaderOnlyOnce || self.isBeingPresented || self.isMovingToParentViewController){
        [[self remoteDataLoader] forceReload];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.localDataLoader.delegate = nil;
    self.searchLocalDataLoader.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    //    if (self.showNetworkReachability){
    //        [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:AFNetworkingReachabilityDidChangeNotification
    //                                                  object:nil];
    //    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshView:(UIRefreshControl *)refresh {
    [self.localDataLoader forceReload];
    [self.remoteDataLoader forceReload];
    [self.collectionView reloadData];
}


#pragma mark - XLDataLoaderDelegate

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader
{
    if (dataLoader == self.remoteDataLoader){
        if (self.loadingPagingEnabled){
            [self.loadingMoreView.activityViewIndicator startAnimating];
        }
    }
    else if (dataLoader == self.searchRemoteDataLoader){
        if (self.searchLoadingPagingEnabled){
            [self.searchLoadingMoreView.activityViewIndicator startAnimating];
        }
        if ([self.searchDisplayController.searchBar isKindOfClass:[XLSearchBar class]]){
            XLSearchBar * searchBar = (XLSearchBar *)self.searchDisplayController.searchBar;
            [searchBar startActivityIndicator];
        }
        
    }
}

-(void)dataLoaderDidLoadData:(XLDataLoader *)dataLoader
{
    if (dataLoader == self.remoteDataLoader){
        [self.loadingMoreView.activityViewIndicator stopAnimating];
        [self.refreshControl endRefreshing];
        if (self.localDataLoader){
            [self.localDataLoader changeOffsetTo:self.remoteDataLoader.offset];
        }
    }
    else if (dataLoader == self.searchRemoteDataLoader){
        [self.searchLoadingMoreView.activityViewIndicator stopAnimating];
        if ([self.searchDisplayController.searchBar isKindOfClass:[XLSearchBar class]]){
            XLSearchBar * searchBar = (XLSearchBar *)self.searchDisplayController.searchBar;
            [searchBar stopActivityIndicator];
        }
        if (self.searchLocalDataLoader){
            [self.searchLocalDataLoader changeOffsetTo:self.searchRemoteDataLoader.offset];
        }
    }
    else if (dataLoader == self.localDataLoader) {
        if (!self.remoteDataLoader) {
            [self.refreshControl endRefreshing];
        }
        [self didChangeGridContent];
    }
    else if (dataLoader == self.searchLocalDataLoader){
        [self didChangeSearchGridContent];
    }
}

-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataLoader withError:(NSError *)error
{
    if ([dataLoader isKindOfClass:[XLRemoteDataLoader class]]){
        if (dataLoader == self.remoteDataLoader)
        {
            [self.loadingMoreView.activityViewIndicator stopAnimating];
            [self.refreshControl endRefreshing];
        }
        else{
            [self.searchLoadingMoreView.activityViewIndicator stopAnimating];
            if ([self.searchDisplayController.searchBar isKindOfClass:[XLSearchBar class]]){
                XLSearchBar * searchBar = (XLSearchBar *)self.searchDisplayController.searchBar;
                [searchBar stopActivityIndicator];
            }
        }
    }
    if (self.localDataLoader == dataLoader && !self.remoteDataLoader){
        [self.refreshControl endRefreshing];
    }
    [self showError:error];
}


-(void)showError:(NSError*)error{
    if (error.code != NSURLErrorCancelled){
        // don't show cancel operation error
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error loading data"
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
        });
    }
}

#pragma mark - Helpers


- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.collectionView reloadData];
}


-(UISearchDisplayController *)createDisplayController
{
    XLSearchBar *searchBar = [[XLSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.bounds.size.width, 44)];
    searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
    UISearchDisplayController *displayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    displayController.delegate = self;
    displayController.searchResultsDataSource = self;
    displayController.searchResultsDelegate = self;
    return displayController;
}


-(BOOL)isLastSection:(NSUInteger)section inTableView:(UITableView*)tableView
{
    return (section == ([self numberOfSectionsInTableView:tableView] - 1));
}

-(BOOL)isLastRowOfSection:(NSUInteger)section row:(NSUInteger)row inTableView:(UITableView*)tableView
{
    return (row == ([self tableView:tableView numberOfRowsInSection:section] - 1));
}

-(BOOL)isLastCellIndex:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return ([self isLastSection:indexPath.section inTableView:tableView] && [self isLastRowOfSection:indexPath.section row:indexPath.row inTableView:tableView]);
}

-(BOOL)isLastSection:(NSUInteger)section inCollectionView:(UICollectionView*)collectionView
{
    return (section == ([self numberOfSectionsInCollectionView:collectionView] - 1));
}

-(BOOL)isLastItemOfSection:(NSUInteger)section item:(NSUInteger)item collectionView:(UICollectionView*)collectionView

{
    return (item == ([self collectionView:collectionView numberOfItemsInSection:section] - 1));
}

-(BOOL)isLastCellIndex:(NSIndexPath *)indexPath collectionView:(UICollectionView*)collectionView

{
    return ([self isLastSection:indexPath.section inCollectionView:collectionView] && [self isLastItemOfSection:indexPath.section item:indexPath.item collectionView:collectionView]);
}

-(NSUInteger)indexWithoutSection:(NSIndexPath *)indexPath localDataLoader:(XLLocalDataLoader *)localDataLoader
{
    if (localDataLoader){
        NSUInteger result = 0;
        for (NSUInteger sectionIndex = 0; sectionIndex < indexPath.section; sectionIndex++) {
            result += [localDataLoader numberOfRowsInSection:sectionIndex];
        }
        result += indexPath.row;
        return result;
    }
    return 0;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.collectionView == collectionView){
        if (self.localDataLoader){
            return [self.localDataLoader numberOfSections];
        }
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView == collectionView){
        if (self.localDataLoader){
            return [self.localDataLoader numberOfRowsInSection:section];
        }
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchDisplayController.searchResultsTableView == tableView){
        if(self.searchLocalDataLoader){
            return [self.searchLocalDataLoader numberOfSections];
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchDisplayController.searchResultsTableView == tableView){
        if (self.searchLocalDataLoader){
            // add numbers of items provided by searchLocalDataLoader
            return [self.searchLocalDataLoader numberOfRowsInSection:section];
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchDisplayController.searchResultsTableView){
        if (self.searchLocalDataLoader){
            return [[[self.searchLocalDataLoader sections] objectAtIndex:section] name];
        }
    }
    return nil;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchDisplayController.searchResultsTableView == tableView){
        if (self.searchLoadingPagingEnabled){
            if ([self isLastCellIndex:indexPath tableView:tableView]){
                if (!self.searchRemoteDataLoader.isLoadingMore){
                    [self.searchLoadingMoreView.activityViewIndicator startAnimating];
                    [self.searchRemoteDataLoader loadMoreForIndex:([self indexWithoutSection:indexPath localDataLoader:self.searchLocalDataLoader] + 1)];
                }
            }
        }
    }
}




#pragma mark - XLLocalDataLoaderDelegate


- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (localDataLoader == self.localDataLoader){
        self.beganUpdates = YES;
    }
    else if (localDataLoader == self.searchLocalDataLoader){
        self.searchBeganUpdates = YES;
        [self.searchDisplayController.searchResultsTableView beginUpdates];
    }
}

- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controller:(NSFetchedResultsController *)controller
       didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
                atIndex:(NSUInteger)sectionIndex
          forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.searchLocalDataLoader == localDataLoader){
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
    else if (self.localDataLoader == localDataLoader){
        NSMutableDictionary *change = [NSMutableDictionary new];
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = @(sectionIndex);
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = @(sectionIndex);
                break;
        }
        
        [_sectionChanges addObject:change];
    }
}


- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader
             controller:(NSFetchedResultsController *)controller
        didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(NSFetchedResultsChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.searchLocalDataLoader == localDataLoader){
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView  insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.searchDisplayController.searchResultsTableView  reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
                [self.searchDisplayController.searchResultsTableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.searchDisplayController.searchResultsTableView  insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
    else if (self.localDataLoader == localDataLoader){
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = newIndexPath;
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeUpdate:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeMove:
                change[@(type)] = @[indexPath, newIndexPath];
                break;
        }
        [_objectChanges addObject:change];
    }
}


- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (localDataLoader == self.localDataLoader)
    {
        if (self.beganUpdates){
            [self localDataLoaderDidChangeContent];
            self.beganUpdates = NO;
        }
        [self didChangeGridContent];
    }
    else if (localDataLoader == self.searchLocalDataLoader)
    {
        if (self.searchBeganUpdates){
            [self.searchDisplayController.searchResultsTableView performSelectorOnMainThread:@selector(endUpdates) withObject:nil waitUntilDone:YES];
            self.searchBeganUpdates = NO;
        }
        [self didChangeSearchGridContent];
    }
    
}


-(void)didChangeGridContent
{
    // overrite this method to do something useful.
    if (self.localDataLoader.totalNumberOfObjects == 0) {
        // Check for self.localDataLoader.totalNumberOfObjects because this method is called before the tableView's data be updated
        if (self.backgroundViewForEmptyCollectionView){
            if (!self.collectionView.backgroundView){
                self.collectionView.backgroundView = [self backgroundViewForEmptyCollectionView];
            }
            [self.backgroundViewForEmptyCollectionView setHidden:NO];
        }
    }
    else{
        [self.collectionView.backgroundView setHidden:YES];
    }
}

-(void)didChangeSearchGridContent
{
    // overrite this method to do something useful.
}

-(BOOL)collectionViewIsEmpty
{
    return (([self.collectionView numberOfSections] == 0) || ([self.collectionView numberOfSections] == 1 && [self.collectionView numberOfItemsInSection:0] == 0));
}

-(BOOL)searchTableIsEmpty
{
    return (([self.searchDisplayController.searchResultsTableView numberOfSections] == 0) || ([self.searchDisplayController.searchResultsTableView numberOfSections] == 1 && [self.searchDisplayController.searchResultsTableView numberOfRowsInSection:0] == 0));
}


- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    [self.localDataLoader setSuspendAutomaticTrackingOfChangesInManagedObjectContext:suspend];
}

- (void)setSuspendAutomaticTrackingOfSearchChangesInManagedObjectContext:(BOOL)suspend
{
    [self.searchLocalDataLoader setSuspendAutomaticTrackingOfChangesInManagedObjectContext:suspend];
}

#pragma mark - UISearchDisplayDelegate

// when we start/end showing the search UI
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.localDataLoader.delegate = nil;
    self.searchLocalDataLoader.delegate = self;
    [self.searchLocalDataLoader forceReload];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchLocalDataLoader.delegate = nil;
    self.localDataLoader.delegate = self;
    [self.localDataLoader forceReload];
    [self.collectionView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (_searchDelayTimer) {
        [_searchDelayTimer invalidate];
        _searchDelayTimer = nil;
    }
    
    _searchDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.500f
                                                         target:self
                                                       selector:@selector(beginRemoteSearch:)
                                                       userInfo:@{ @"searchString" : [searchString copy] }
                                                        repeats:NO];
    [self.searchLocalDataLoader changeSearchString:[searchString copy]];
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

///
- (void)beginRemoteSearch:(NSTimer *)sender
{
    if (self.searchRemoteDataLoader)
    {
        NSString *filter = sender.userInfo[@"searchString"];
        if ([self.searchDisplayController.searchBar isKindOfClass:[XLSearchBar class]]){
            XLSearchBar * searchBar = (XLSearchBar *)self.searchDisplayController.searchBar;
            [searchBar startActivityIndicator];
        }
        [self.searchRemoteDataLoader changeSearchString:filter];
        
        _searchDelayTimer = nil;
    }
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.networkStatusView.frame;
    frame.origin.y = MAX(scrollView.contentOffset.y + scrollView.contentInset.top, 0);
    self.networkStatusView.frame = frame;
}


#pragma mark - Helpers


- (void)localDataLoaderDidChangeContent
{
    if ([_sectionChanges count] > 0){
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges){
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0){
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        }
        else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}



@end
