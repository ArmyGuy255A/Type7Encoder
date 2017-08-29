//
//  T7EDetailViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@interface T7EDetailViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UIGestureRecognizerDelegate> {
    UITableViewCell *tvCell;
}

@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Device *device;

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setupNavBar;
-(void)addNewPassword;
@end
