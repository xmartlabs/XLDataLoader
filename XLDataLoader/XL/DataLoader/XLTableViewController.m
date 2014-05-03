//
//  XLStoryBoardTableViewController.m
//  XLDataLoader
//
//  Created by Martin Barreto on 4/24/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//

#import "XLRemoteDataLoader.h"
#import "XLLoadingMoreView.h"
#import "XLNetworkStatusView.h"
#import "XLSearchBar.h"
#import "UIScrollView+SVInfiniteScrolling.h"


#import "XLTableViewController.h"

@protocol FixSetSearchViewController <NSObject>

@optional

-(void)setSearchDisplayController:(UISearchDisplayController *)searchDisplayController;

@end

@interface XLTableViewController () <XLRemoteDataLoaderDelegate, XLLocalDataLoaderDelegate>
{
    NSTimer * _searchDelayTimer;
}

@property BOOL beganUpdates;
@property BOOL searchBeganUpdates;

@property (nonatomic) XLNetworkStatusView * networkStatusView;
@property (readonly) BOOL searchLoadingPagingEnabled;


@end

@implementation XLTableViewController

@synthesize tableView = _tableView;
@synthesize refreshControl = _refreshControl;

@synthesize remoteDataLoader = _remoteDataLoader;
@synthesize localDataLoader  = _localDataLoader;

@synthesize searchRemoteDataLoader = _searchRemoteDataLoader;
@synthesize searchLocalDataLoader  = _searchLocalDataLoader;

@synthesize fetchFromRemoteDataLoaderOnlyOnce = _fetchFromRemoteDataLoaderOnlyOnce;

@synthesize beganUpdates     = _beganUpdates;
@synthesize searchBeganUpdates = _searchBeganUpdates;

@synthesize networkStatusView = _networkStatusView;

@synthesize supportRefreshControl = _supportRefreshControl;
@synthesize loadingPagingEnabled = _loadingPagingEnabled;

@synthesize supportSearchController = _supportSearchController;

@synthesize backgroundViewForEmptyTableView = _backgroundViewForEmptyTableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) [self initializeController];
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeController];
}


-(void)initializeController{
    _searchDelayTimer = nil;
    // Dataloaders
    self.remoteDataLoader = nil;
    self.localDataLoader  = nil;
    self.searchRemoteDataLoader = nil;
    self.searchLocalDataLoader = nil;
    // table configuration
    self.supportRefreshControl = YES;
    self.loadingPagingEnabled = YES;
    self.supportSearchController = NO;
    self.showNetworkReachability = YES;
    self.tableViewStyle = UITableViewStylePlain;

}

#pragma mark - Properties

-(UISearchBar *)searchBar
{
    if (!_searchBar){
        _searchBar = [[XLSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
        _searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
    }
    return _searchBar;
}

-(UIRefreshControl *)refreshControl
{
    if (_refreshControl) return _refreshControl;
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    return _refreshControl;
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
    if (!self.tableView){
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                    style:self.tableViewStyle];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if (!self.tableView.superview){
        [self.view addSubview:self.tableView];;
    }
    if (!self.tableView.delegate){
        self.tableView.delegate = self;
    }
    if (!self.tableView.dataSource){
        self.tableView.dataSource = self;
    }
    if (self.supportSearchController && !self.searchDisplayController){
        UISearchDisplayController * searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate = self;
        [self performSelector:@selector(setSearchDisplayController:) withObject:searchDisplayController];
    }
    if (self.loadingPagingEnabled == NO){
        [[self localDataLoader] setLimit:0];
    }
    [[self localDataLoader] forceReload];
    // initialize refresh Control
    if (self.supportRefreshControl){
        [self.tableView addSubview:self.refreshControl];
    }
    if (self.loadingPagingEnabled){
        __typeof__(self) __weak weakSelf = self;
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            if (!weakSelf.remoteDataLoader.isLoadingMore){
                [weakSelf.tableView.infiniteScrollingView startAnimating];
                [weakSelf.remoteDataLoader loadMoreForIndex:[weakSelf.localDataLoader totalNumberOfObjects]];
            }
            else{
               // [weakSelf.tableView.infiniteScrollingView stopAnimating];
            }
        }];
    }
    if (self.searchLoadingPagingEnabled){
         __typeof__(self) __weak weakSelf = self;
        [self.searchDisplayController.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
            if (!self.searchRemoteDataLoader.isLoadingMore){
                [self.searchDisplayController.searchResultsTableView.infiniteScrollingView startAnimating];
                [self.searchRemoteDataLoader loadMoreForIndex:[weakSelf.searchLocalDataLoader totalNumberOfObjects]];
            }
        }];

    }
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.remoteDataLoader.delegate = self;
    self.localDataLoader.delegate = self;
    [[self tableView] reloadData];
    self.searchRemoteDataLoader.delegate = self;
    if (self.searchDisplayController.isActive){
        self.searchLocalDataLoader.delegate = self;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.localDataLoader.delegate = nil;
    self.searchLocalDataLoader.delegate = nil;
    self.searchLocalDataLoader.delegate = nil;
    self.searchRemoteDataLoader.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
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


-(UIView *)tableViewFooter:(UITableView *)tableView
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - XLDataLoaderDelegate

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader
{
    if (dataLoader == self.remoteDataLoader){
        if (self.loadingPagingEnabled){
            [self.tableView.infiniteScrollingView startAnimating];
        }
    }
    else if (dataLoader == self.searchRemoteDataLoader){
        if (self.searchLoadingPagingEnabled){
            [self.searchDisplayController.searchResultsTableView.infiniteScrollingView startAnimating];
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
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.refreshControl endRefreshing];
        if (self.localDataLoader){
            
            [self.localDataLoader changeOffsetTo:self.remoteDataLoader.offset];
            //self.tableView
            //[self.tableView reloadData];
        }
    }
    else if (dataLoader ==  self.searchRemoteDataLoader){
        [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
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
    else if (dataLoader == self.searchLocalDataLoader) {
        [self didChangeSearchGridContent];
    }
}

-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataLoader withError:(NSError *)error
{
    if ([dataLoader isKindOfClass:[XLRemoteDataLoader class]]){
        if (dataLoader == self.remoteDataLoader){
            [self.tableView.infiniteScrollingView stopAnimating];
            [self.refreshControl endRefreshing];
        }
        else{
            [self.searchDisplayController.searchResultsTableView.infiniteScrollingView  stopAnimating];
            if ([self.searchDisplayController.searchBar isKindOfClass:[XLSearchBar class]]){
                XLSearchBar * searchBar = (XLSearchBar *)self.searchDisplayController.searchBar;
                [searchBar stopActivityIndicator];
            }
        }
    }
    if (self.localDataLoader == dataLoader && !self.remoteDataLoader){
        [self.refreshControl endRefreshing];
    }
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


-(UISearchDisplayController *)createSearchDisplayController
{
    XLSearchBar *searchBar = [[XLSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    searchBar.showsCancelButton = YES;
    UISearchDisplayController * searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    return searchDisplayController;
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
            [self.tableView endUpdates];
            self.beganUpdates = NO;
        }
        [self didChangeGridContent];
    }
    else if (localDataLoader == self.searchLocalDataLoader)
    {
        if (self.searchBeganUpdates){
            [self.searchDisplayController.searchResultsTableView endUpdates];
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

///
- (void)beginRemoteSearch:(NSTimer *)sender
{
    if (self.searchRemoteDataLoader){
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
