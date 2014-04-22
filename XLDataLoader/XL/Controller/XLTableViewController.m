//
//  XLTableViewController.m
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

#import "XLTableViewController.h"
#import "XLRemoteDataLoader.h"
#import "XLLoadingMoreView.h"
#import "XLNetworkStatusView.h"
#import "XLSearchBar.h"

@protocol FixSetSearchViewController <NSObject>

@optional

-(void)setSearchDisplayController:(UISearchDisplayController *)searchDisplayController;

@end

@interface XLTableViewController () <XLRemoteDataLoaderDelegate, XLLocalDataLoaderDelegate, FixSetSearchViewController>
{
    NSTimer * _searchDelayTimer;
}

@property BOOL beganUpdates;
@property BOOL searchBeganUpdates;
@property (nonatomic) XLLoadingMoreView * loadingMoreView;
@property (nonatomic) XLLoadingMoreView * searchLoadingMoreView;
@property (nonatomic) XLNetworkStatusView * networkStatusView;

@property (readonly) BOOL searchLoadingPagingEnabled;

@end

@implementation XLTableViewController

@synthesize remoteDataLoader = _remoteDataLoader;
@synthesize localDataLoader  = _localDataLoader;

@synthesize searchRemoteDataLoader = _searchRemoteDataLoader;
@synthesize searchLocalDataLoader  = _searchLocalDataLoader;

@synthesize fetchFromRemoteDataLoaderOnlyOnce = _fetchFromRemoteDataLoaderOnlyOnce;

@synthesize beganUpdates     = _beganUpdates;
@synthesize searchBeganUpdates = _searchBeganUpdates;


@synthesize loadingMoreView  = _loadingMoreView;
@synthesize searchLoadingMoreView = _searchLoadingMoreView;
@synthesize networkStatusView = _networkStatusView;

@synthesize showNetworkReachability = _showNetworkReachability;


@synthesize supportRefreshControl = _supportRefreshControl;
@synthesize loadingPagingEnabled = _loadingPagingEnabled;

@synthesize supportSearchController = _supportSearchController;

@synthesize backgroundViewForEmptyTableView = _backgroundViewForEmptyTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
        _networkStatusView = [[XLNetworkStatusView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
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

-(void)setBackgroundViewForEmptyTableView:(UIView *)backgroundViewForEmptyTableView
{
    _backgroundViewForEmptyTableView = backgroundViewForEmptyTableView;
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
    if (self.loadingPagingEnabled == NO){
        [[self localDataLoader] setLimit:0];
    }
    [[self localDataLoader] forceReload];
    // initialize refresh Control
    if (self.supportRefreshControl){
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    }
    if (self.loadingPagingEnabled){
        self.tableView.tableFooterView = self.loadingMoreView;
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
    [[self tableView] reloadData];
    if (self.searchDisplayController.isActive){
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    if (!self.fetchFromRemoteDataLoaderOnlyOnce || self.isBeingPresented || self.isMovingToParentViewController){
        [[self remoteDataLoader] forceReload];
    }
    if (self.showNetworkReachability && self.remoteDataLoader){
        [self updateNetworkReachabilityView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkingReachabilityDidChange:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
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
    if (self.showNetworkReachability){
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
                                                  object:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshView:(UIRefreshControl *)refresh {
    [self.localDataLoader forceReload];
    [self.remoteDataLoader forceReload];
    [self.tableView reloadData];
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
    [self.tableView reloadData];
}

-(void)networkingReachabilityDidChange:(NSNotification *)notification
{
    [self updateNetworkReachabilityView];
}

-(void)updateNetworkReachabilityView
{
    if (![self.remoteDataLoader.sessionManager.reachabilityManager networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable){
        if ([self.networkStatusView superview]){
            [self.networkStatusView removeFromSuperview];
        }
    }
    else{
        if (![self.networkStatusView superview]){
            [self.tableView addSubview:self.networkStatusView];
        }
    }
}

-(UISearchDisplayController *)createDisplayController
{
    XLSearchBar *searchBar = [[XLSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
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

-(UITableView *)localDataLoaderTable:(XLLocalDataLoader *)localDataLoader
{
    if (localDataLoader == self.localDataLoader){
        return self.tableView;
    }
    else if (localDataLoader == self.searchLocalDataLoader){
        return self.searchDisplayController.searchResultsTableView;
    }
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView){
        if (self.localDataLoader){
            return [self.localDataLoader numberOfSections];
        }
    }
    else if (self.searchDisplayController.searchResultsTableView == tableView){
        if(self.searchLocalDataLoader){
            return [self.searchLocalDataLoader numberOfSections];
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView){
        if (self.localDataLoader){
            // add numbers of items provided by localDataLoader
            return [self.localDataLoader numberOfRowsInSection:section];
        }
    }
    else if (self.searchDisplayController.searchResultsTableView == tableView){
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
    if (self.tableView == tableView)
    {
        if (self.localDataLoader && !self.searchDisplayController.isActive) {
            // Just return the section title for self.tableView when the searchDisplayController is not active, this
            // fix issue "Tableview's sections are shown over the searchDisplayController.searchResultsTableView"
            return [[[self.localDataLoader sections] objectAtIndex:section] name];
        }
        return nil;
    }
    else if (self.searchDisplayController.searchResultsTableView)
    {
        if (self.searchLocalDataLoader){
            return [[[self.searchLocalDataLoader sections] objectAtIndex:section] name];
        }
        return nil;
    }
    return nil;
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView == tableView){
        if (self.loadingPagingEnabled){
            if ([self isLastCellIndex:indexPath tableView:tableView]){
                if (!self.remoteDataLoader.isLoadingMore){
                    [self.loadingMoreView.activityViewIndicator startAnimating];
                    [self.remoteDataLoader loadMoreForIndex:([self indexWithoutSection:indexPath localDataLoader:self.localDataLoader] + 1)];
                }
            }
        }
    }
    else if (self.searchDisplayController.searchResultsTableView == tableView)
    {
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
        [self.tableView beginUpdates];
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
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [[self localDataLoaderTable:localDataLoader] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self localDataLoaderTable:localDataLoader] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader
             controller:(NSFetchedResultsController *)controller
        didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(NSFetchedResultsChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [[self localDataLoaderTable:localDataLoader] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self localDataLoaderTable:localDataLoader] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [[self localDataLoaderTable:localDataLoader] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [[self localDataLoaderTable:localDataLoader] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self localDataLoaderTable:localDataLoader] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)localDataLoader:(XLLocalDataLoader *)localDataLoader controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (localDataLoader == self.localDataLoader)
    {
        if (self.beganUpdates){
            [self.tableView performSelectorOnMainThread:@selector(endUpdates) withObject:nil waitUntilDone:YES];
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
        if (self.backgroundViewForEmptyTableView){
            if (!self.tableView.backgroundView){
                self.tableView.backgroundView =[self backgroundViewForEmptyTableView];
            }
            [self.backgroundViewForEmptyTableView setHidden:NO];
        }
    }
    else{
        [self.tableView.backgroundView setHidden:YES];
    }
}

-(void)didChangeSearchGridContent
{
    // overrite this method to do something useful.
}

-(BOOL)tableIsEmpty
{
    return (([self.tableView numberOfSections] == 0) || ([self.tableView numberOfSections] == 1 && [self.tableView numberOfRowsInSection:0] == 0));
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
    [self.tableView reloadData];
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

// Search Table View Footer
- (void)searchDisplayController: (UISearchDisplayController *)controller
 willShowSearchResultsTableView: (UITableView *)searchTableView
{
    searchTableView.tableFooterView  = self.searchLoadingPagingEnabled ? self.searchLoadingMoreView : [[UIView alloc] initWithFrame:CGRectZero];
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

@end
