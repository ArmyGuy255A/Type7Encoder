//
//  T7EMasterViewController.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "T7EMasterViewController.h"

#import "T7EDetailViewController.h"

#import "PasswordViewController.h"

#import "CustomCellBackground.h"

@implementation T7EMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Devices", @"Devices");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
            
        }
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setBackgroundColor:color4];
    [self.tableView setSeparatorColor:[UIColor clearColor]];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNavBar];
    
    [self.fetchedResultsController setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    } else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}
 */

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id bgView = [[CustomCellBackground alloc] init];
    //[bgView setTheBaseColor:[UIC];
    [bgView setTheStartColor:color4];
    [bgView setTheEndColor:color1];
    
    //label title
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 400, 25)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [bgView addSubview:sectionLabel];
    
    
    NSString *value = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    [sectionLabel setText:value];
    
    return bgView;
}

// Customize the appearance of table view cells.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Create the gradient background
    id bgView = [[CustomCellBackground alloc] init];
    //Set the start and end colors of the gradient
    [bgView setTheStartColor:color3];
    [bgView setTheEndColor:color2];
    //assign the backgroundView   
    cell.backgroundView = bgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        /*
        UISplitViewController *svc = (UISplitViewController *)[[AppDelegate window] rootViewController];
        UINavigationController *dtNVC = [[svc viewControllers] objectAtIndex:1];
        T7EDetailViewController *detailViewController = (T7EDetailViewController *)[dtNVC topViewController];
        detailViewController.fetchedResultsController = nil;
        [dtNVC popToRootViewControllerAnimated:YES];
         */
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	           
        T7EDetailViewController *dtvc = [[T7EDetailViewController alloc] init];
        Device *selectedObject = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [dtvc setDevice:selectedObject];
        [self.navigationController pushViewController:dtvc animated:YES];
    } else {
        UISplitViewController *svc = (UISplitViewController *)[[AppDelegate window] rootViewController];
        UINavigationController *nvc = [[svc viewControllers] objectAtIndex:1];
        //Pop to the rootViewController of the detailViewController
        [nvc popToRootViewControllerAnimated:NO];
        
        //Capture the selected object
        Device *selectedObject = (Device *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        T7EDetailViewController *t7eDTVC = [[T7EDetailViewController alloc] init];
        [t7eDTVC setDevice:selectedObject];
        //self.detailViewController = t7eDTVC;
        //[navcon popToRootViewControllerAnimated:NO];
        [nvc pushViewController:t7eDTVC animated:YES];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];

        [self.detailViewController.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"model" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"hostname" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"model" cacheName:@"Devices"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    //Add touch to hold gesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.delegate = self;
    [cell addGestureRecognizer:longPressGesture];

    Device *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    //Set the detailTextLabel
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:[AppDelegate managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device=%@", [device objectID]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    //Set the main label
    [cell.textLabel setText:[device hostname]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:colorAccent];
    
    //Set the detail text label
    NSString *detailText = [NSString stringWithFormat:@"Passwords: %i", [fetchedObjects count]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setText:detailText];
    [cell.detailTextLabel setTextColor:color1];
    
}

#pragma mark - Custom Implementation

-(void)setupNavBar {
    UIBarButtonItem *dButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Decoder", @"Decoder") style:UIBarButtonItemStyleBordered target:self action:@selector(showDecryptor)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewDevice)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = dButton;
        self.navigationItem.rightBarButtonItem = addButton;
    } else {
        self.navigationItem.rightBarButtonItem = addButton;
    }
    //Show the editButton.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}

-(void)addNewDevice {
    [ActionClass pushDeviceVC:nil withTitle:nil];
}
-(void)showDecryptor {
    PasswordViewController *piv = [[PasswordViewController alloc] init];
    //[piv setDevice:nil];
    [piv setPassword:[ActionClass addNewPassword:nil]];
    
    [self.navigationController pushViewController:piv animated:YES];
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Device *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [ActionClass pushDeviceVC:device withTitle:nil];
                
    }
}


@end
