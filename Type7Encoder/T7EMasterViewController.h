//
//  T7EMasterViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 WO1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class T7EDetailViewController;

#import <CoreData/CoreData.h>

@interface T7EMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) T7EDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
