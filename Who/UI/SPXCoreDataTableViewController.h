//
//  CLTableViewController.h
//  Review
//
//  Created by Shahpour Mohsenin on 26/01/2011.
//  Copyright (c) 2012 Code Bendaz. All rights reserved.
//

#import "SPXTableViewControllerDatasource.h"

/**
 Note* This is a really old class I created 2 years ago and have just reused a lot. It definitely could do with improving so please ignore this file.
 
 The purpose of this class is to encapsulate all the generic work required to setup a UITableViewController to use CoreData as its backing source.
 You only have to ensure you implement a few methods defined in SPXTableViewControllerDatasource.h and you will have search, ordering, filtering and all animation handled for you. Great for fast prototyping.
 */

@interface SPXCoreDataTableViewController : UITableViewController
                                            <NSFetchedResultsControllerDelegate,
                                            SPXCoreDataTableViewControllerDatasource,
                                            UISearchBarDelegate, UISearchDisplayDelegate>
{
	NSString *_savedSearchTerm;
	NSInteger _savedScopeButtonIndex;
	id editingObject;
}

@property (nonatomic, strong, readonly) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) id <SPXCoreDataTableViewControllerDatasource> datasource;

-(void)reloadFetchedResults;

@end