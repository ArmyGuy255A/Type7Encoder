//
//  T7EDetailViewController.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "T7EDetailViewController.h"

#import "CustomCellBackground.h"

#import "PasswordViewController.h"

#import "Password.h"

#import "decrypt.h"


@implementation T7EDetailViewController

@dynamic tvCell;
@synthesize device = _device;
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - Managing the detail item



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = NSLocalizedString(@"Passwords", @"Passwords");
    
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
    
    [ActionClass collapseAllPasswords:nil];
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"TextFieldCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil];
        cell = tvCell;
        tvCell = nil;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        [self configureCell:cell atIndexPath:indexPath];
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    Password *password = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([[password expanded] boolValue]) {
        [ActionClass collapseAllPasswords:nil];
    } else {
        [ActionClass collapseAllPasswords:nil];
        [password setExpanded:[NSNumber numberWithBool:YES]];
    }
       
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    [self.tableView endUpdates];
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 40;
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        Password *password = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([[password expanded] boolValue]) {
            height = 80;
        }
    }
        
    return height;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"device" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device=%@", [self.device objectID]];
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[AppDelegate managedObjectContext] sectionNameKeyPath:@"title" cacheName:@"Passwords"];
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
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    UITextField *textField;
    textField = (UITextField *)[cell viewWithTag:1];
    [textField setTextColor:color1];
    [textField setFont:[UIFont boldSystemFontOfSize:18]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    [label setTextColor:colorAccent];
    [label setBackgroundColor:[UIColor clearColor]];
    
    
    Password *password = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[password expanded]boolValue]) {
        NSString *passwd = [decrypt type7:[password passwd]];
        [label setText:passwd];
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setHidden:NO];
        [textField setText:[password passwd]];
        [textField setAdjustsFontSizeToFitWidth:YES];
    } else {
        [textField setText:[password passwd]];
        [textField setAdjustsFontSizeToFitWidth:YES];
        [label setHidden:YES];
    }
    
}

							


#pragma mark - Custom Implementaion

-(void)setupNavBar {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPassword)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)addNewPassword {
    
    PasswordViewController *piv = [[PasswordViewController alloc] init];
    [piv setDevice:self.device];
    [self.navigationController pushViewController:piv animated:YES];
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Password *password = [self.fetchedResultsController objectAtIndexPath:indexPath];
        PasswordViewController *piv = [[PasswordViewController alloc] init];
        [piv setDevice:self.device];
        [piv setPassword:password];
        [self.navigationController pushViewController:piv animated:YES];
        
    }
}

@end
