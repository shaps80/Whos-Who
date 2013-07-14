/*
   Copyright (c) 2013 Snippex. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY Snippex `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Snippex OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXPeopleTableViewController.h"
#import "SPXUpdateManager.h"
#import "SPXImageCache.h"
#import "SPXStoreManager.h"
#import "SPXPersonCell.h"
#import "SPXPerson.h"
#import "SPXLoadingViewController.h"

@interface SPXPeopleTableViewController()
@property (nonatomic, weak) SPXLoadingViewController *loadingViewController;
@end

@implementation SPXPeopleTableViewController

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self
                            action:@selector(handleRefreshControl:)
                  forControlEvents:UIControlEventValueChanged];

    _currentIndex = -1;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:[NSBundle mainBundle]];
    _loadingViewController = [storyboard instantiateViewControllerWithIdentifier:@"loadingViewController"];
    [_loadingViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [self presentViewController:_loadingViewController animated:NO completion:nil];
    [self update];

    [_loadingViewController.refreshButton addTarget:self
                                             action:@selector(loadingViewControllerRefreshTapped:)
                                   forControlEvents:UIControlEventTouchUpInside];
}

-(void)loadingViewControllerRefreshTapped:(id)sender
{
    [self update];
}

-(void)update
{
    _loadingViewController.label.text = @"Downloading Updates...";
    [_loadingViewController start];

    SPXStore *store = [SPXStoreManager storeWithName:@"Who"];

    SPXPeopleTableViewController * __weak weakSelf = self;
    [[SPXUpdateManager sharedInstance] updateWithContext:store.managedObjectContext
                                              completion:^(NSError *error)
     {
         if (!error)
         {
             if (weakSelf.fetchedResultsController.fetchedObjects.count)
                 [weakSelf dismissViewControllerAnimated:YES completion:nil];
             else
                 _loadingViewController.label.text = @"No Contacts Found";
         }
         else
             _loadingViewController.label.text = @"Download Failed";

         [_loadingViewController stop];
         [weakSelf.refreshControl endRefreshing];

         [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]
                                         animated:NO
                                   scrollPosition:UITableViewScrollPositionNone];
     }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.fetchedResultsController.fetchedObjects.count > 7)
        [self hideNavigationBar];
}

-(void)handleRefreshControl:(id)sender
{
    if ([self.refreshControl isRefreshing])
        [self update];
}

-(void)showNavigationBar
{
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)hideNavigationBar
{
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - CoreData Configuration

-(NSString *)entityName
{
    return @"Person";
}

-(NSArray *)sortDescriptors
{
    return @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
}

-(NSString *)cellIdentifierForTableView:(UITableView *)tableView
{
    return @"personCell";
}

-(NSManagedObjectContext *)managedObjectContext
{
    SPXStore *store = [SPXStoreManager storeWithName:@"Who"];
    return store.managedObjectContext;
}

-(void)fetchedResultsController:(NSFetchedResultsController *)controller
                  configureCell:(SPXPersonCell *)cell
                    atIndexPath:(NSIndexPath *)indexPath
{
    SPXPerson *person = [controller objectAtIndexPath:indexPath];

    cell.nameLabel.text = [person.name capitalizedString];
    cell.roleLabel.text = [person.role capitalizedString];
    [cell setBiographyText:person.biography];

    UITableView * __weak tableView  = self.tableView;

    [[SPXImageCache sharedInstance] imageForPerson:person withCompletion:^(UIImage *image)
    {
        if ([tableView.visibleCells containsObject:cell])
            cell.profileImageView.image = image;
    }];
}

#pragma mark - TableView Delegate and Datasource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];

    // if we are already selected, collapse, otherwise expand
    if (_currentIndex == indexPath.row)
    {
        _currentIndex = -1;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
        _currentIndex = indexPath.row;
    
    [tableView endUpdates];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentIndex == indexPath.row)
    {
        SPXPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
        return [SPXPersonCell requiredHeightWithBiographyText:person.biography];
    }
    else
        return 72;
}

#pragma mark - ScrollView delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.fetchedResultsController.fetchedObjects count] < 8) return;
    
    CGFloat currentOffset       = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast  = lastContentOffset - currentOffset;
    lastContentOffset           = currentOffset;

    if (differenceFromStart < 0)
    {
        // scrolling up
        if (scrollView.isTracking && abs(differenceFromLast) > 1)
            [self hideNavigationBar];
    }
    else
    {
        // scrolling down
        if (scrollView.isTracking && abs(differenceFromLast) > 1)
            [self showNavigationBar];
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [self showNavigationBar];
    return YES;
}

@end
