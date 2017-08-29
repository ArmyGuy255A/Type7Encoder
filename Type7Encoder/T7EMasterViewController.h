//
//  T7EMasterViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DeviceViewController.h"

#import "PasswordViewController.h"

#import "Device.h"

@class T7EDetailViewController;

#import <CoreData/CoreData.h>

@interface T7EMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) PasswordViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setupNavBar;
-(void)addNewDevice;
@end
