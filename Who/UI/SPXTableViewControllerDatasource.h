//
//  SLCoreDataTableViewControllerDatasource.h
//  SLKit
//
//  Created by Shaps Mohsenin on 10/02/13.
//  Copyright (c) 2013 Shaps Mohsenin. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol SPXCoreDataTableViewControllerDatasource <NSObject>

@required
-(NSString *)entityName;
-(NSArray *)sortDescriptors;
-(NSString *)cellIdentifierForTableView:(UITableView *)tableView;
-(void)fetchedResultsController:(NSFetchedResultsController *)controller
				  configureCell:(UITableViewCell *)cell
					atIndexPath:(NSIndexPath *)indexPath;
-(NSManagedObjectContext *)managedObjectContext;

@optional
-(NSPredicate *)predicate;
-(NSString *)sectionNameKeyPath;
-(NSString *)cacheName;

@end