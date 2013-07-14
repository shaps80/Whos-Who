//
//  CLTableViewController.m
//  Review
//
//  Created by Shahpour Mohsenin on 26/01/2012.
//  Copyright (c) 2012 Code Bendaz. All rights reserved.
//

#import "SPXCoreDataTableViewController.h"

@interface SPXCoreDataTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation SPXCoreDataTableViewController

#pragma mark - Cell population

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return (tableView == self.tableView) ? self.fetchedResultsController : self.searchFetchedResultsController;
}

-(void)fetchedResultsController:(NSFetchedResultsController *)controller configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	NSAssert(NO, @"you MUST override this in your subclass");
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = PERFORM_SELECTOR_WITH_ARG(self.datasource, @selector(cellIdentifierForTableView:), self.tableView);
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
        cell = PERFORM_SELECTOR_WITH_ARG(self.datasource, @selector(cellForRowAtindexPath:), indexPath);
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
	
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }

    return numberOfRows;
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    _savedScopeButtonIndex = scope;
}

#pragma mark Search Bar

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];

    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];

    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
	[self.tableView reloadData];
}

#pragma mark - Lifecycle

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	_savedSearchTerm = [self.searchDisplayController.searchBar text];
	_savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)didReceiveMemoryWarning
{
    _savedSearchTerm = [self.searchDisplayController.searchBar text];
    _savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];

    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    _searchFetchedResultsController.delegate = nil;
    _searchFetchedResultsController = nil;

    [super didReceiveMemoryWarning];
}

-(void)reloadFetchedResults
{
	_fetchedResultsController = nil;
    [self.tableView reloadData];
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	self.datasource = self;
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
	self.datasource = self;
	
    [super viewDidLoad];

    self.tableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
	self.searchDisplayController.searchResultsTableView.sectionIndexMinimumDisplayRowCount = NSIntegerMax;

	if (_savedSearchTerm)
    {
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:_savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        _savedSearchTerm = nil;
    }

	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
}

-(BOOL)supportsRefreshControl
{
	return NO;
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    
    [NSFetchedResultsController deleteCacheWithName:PERFORM_SELECTOR(self.datasource, @selector(cacheName))];
}

#pragma TableViewController methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
        // Save the context.
		NSError *error;
		if (![context save:&error]) {
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}   
    
    [self.tableView setEditing:NO animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sections = self.fetchedResultsController.sections;

    if(sections.count > 0) 
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        return [sectionInfo name];
    } 
    
    return nil;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        NSMutableArray *chars = [[@[UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                                  [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]] mutableCopy];
        id item = [chars lastObject];
        [chars removeLastObject];
        [chars insertObject:item atIndex:1];
        return chars;
    }
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        }
        else if ([title isEqual: @"#"])
        {
            CGRect rect = self.searchDisplayController.searchBar.frame;
            rect.origin.x = self.searchDisplayController.searchBar.frame.size.height;
            [tableView scrollRectToVisible:rect animated:NO];
            return -1;
        }
        else 
        {
            for (int i = [[self.fetchedResultsController sections] count] -1; i >=0; i--) {
                NSComparisonResult cr = 
                [title caseInsensitiveCompare:
                 [[[self.fetchedResultsController sections] objectAtIndex:i] indexTitle]];
                if (cr == NSOrderedSame || cr == NSOrderedDescending) {
                    return i;
                }
            }
            return 0;
        }
    }
}

#pragma mark - FetchedResultsController methods

- (NSFetchedResultsController *)fetchedResultsControllerWithSearch:(NSString *)searchString
{
	NSPredicate *filterPredicate = PERFORM_SELECTOR(self.datasource, @selector(predicate));

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:PERFORM_SELECTOR(self.datasource, @selector(entityName)) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    fetchRequest.sortDescriptors = PERFORM_SELECTOR(self.datasource, @selector(sortDescriptors));

	NSMutableArray *predicateArray = [NSMutableArray array];

    if(searchString.length)
    {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString]];
		[predicateArray addObject:[NSPredicate predicateWithFormat:@"location CONTAINS[cd] %@", searchString]];

        if(filterPredicate)
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray], nil]];
        else
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
    }
	
    fetchRequest.predicate = filterPredicate;
	
    [NSFetchedResultsController deleteCacheWithName:PERFORM_SELECTOR(self.datasource, @selector(cacheName))];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																							   managedObjectContext:self.managedObjectContext
																								 sectionNameKeyPath:PERFORM_SELECTOR(self.datasource, @selector(sectionNameKeyPath))
																										  cacheName:PERFORM_SELECTOR(self.datasource, @selector(cacheName))];
    fetchedResultsController.delegate = self;

    NSError *error;
    if (![fetchedResultsController performFetch:&error])
	{
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
        return _fetchedResultsController;

    _fetchedResultsController = [self fetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil)
        return _searchFetchedResultsController;

    _searchFetchedResultsController = [self fetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return _searchFetchedResultsController;
}

#pragma mark - Table content updates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	UITableView *tableView = (controller == self.fetchedResultsController) ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
	UITableView *tableView = (controller == self.fetchedResultsController) ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			editingObject = anObject;
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
			[self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			editingObject = anObject;
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	UITableView *tableView = (controller == self.fetchedResultsController) ? self.tableView : self.searchDisplayController.searchResultsTableView;

    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
	[tableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:editingObject] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Datasource

-(NSString *)entityName
{
    NSAssert(0, @"Requires entity name");
    return nil;
}

-(NSArray *)sortDescriptors
{
    NSAssert(0, @"Requires array of NSSortDescriptor's");
    return nil;
}

-(NSString *)cellIdentifierForTableView:(UITableView *)tableView
{
    NSAssert(0, @"Requires cell identifier");
    return nil;
}

-(NSManagedObjectContext *)managedObjectContext
{    
    return nil;
}

@end
