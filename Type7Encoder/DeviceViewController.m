//
//  DeviceViewController.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/3/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "DeviceViewController.h"
#import "PasswordViewController.h"
#define textFieldTAG 1
#define labelTAG 2

@implementation DeviceViewController

@dynamic tvCell;
@synthesize device;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];


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
    [self.tableView setEditing:YES animated:NO];
    
    NSIndexSet *indexSet0 = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet0 withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView.superview setBackgroundColor:[UIColor blackColor]];
    [self.tableView setBackgroundColor:color4];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //reload the passwords
    //NSIndexSet *indexSet0 = [NSIndexSet indexSetWithIndex:0];
    NSIndexSet *indexSet1 = [NSIndexSet indexSetWithIndex:1];
    [self.tableView beginUpdates];
    //[self.tableView reloadSections:indexSet0 withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadSections:indexSet1 withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resignTextFieldFirstResponder];
    
    if ((self.device.hostname == nil || [self.device.hostname isEqualToString:@""]) && 
        (self.device.model == nil || [self.device.model isEqualToString:@""]) && self.device.passwords.count == 0) {
        [[AppDelegate managedObjectContext] deleteObject:self.device];
        return;
    }
    
    if (self.device.model == nil) {
        [self.device setModel:@"Model Name"];
    }
    
    if (self.device.hostname == nil) {
        [self.device setHostname:@"Hostname"];
    }
    
    
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

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Perform an action when the button on the left side is pressed.    
    [self.tableView beginUpdates];
    NSArray *paths = [NSArray arrayWithObjects:indexPath, nil];
    switch (indexPath.section) {
        case 1:
            //only the last row will add objects.
            if (editingStyle == UITableViewCellEditingStyleInsert) {
                //The last row will add objects
                PasswordViewController *piv = [[PasswordViewController alloc] init];
                [piv setDevice:self.device];
                [piv setPassword:[ActionClass addNewPassword:device]];
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];

                
                [self.navigationController pushViewController:piv animated:YES];

               
            } else if (editingStyle == UITableViewCellEditingStyleDelete){
                //Get the password and delete it.
                Password *password = [[[device passwords] allObjects] objectAtIndex:indexPath.row];
                [device removePasswordsObject:password]; 
                [[AppDelegate managedObjectContext] deleteObject:password];
                
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
            /*
             The beginning rows will delete objects if:
             a. there is more than 1 row (password)
             b. its not the last row in the section
            
            if ([tableView numberOfRowsInSection:indexPath.section] > 1 && 
                indexPath.row < [tableView numberOfRowsInSection:indexPath.section] - 1) {
                
                            
            } else {
                
            }
            */
            break;
        default:
            break;
    }
    [self.tableView endUpdates];
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            //Permanent information
            [[tableView cellForRowAtIndexPath:indexPath] setEditing:NO];
            return UITableViewCellEditingStyleNone;
            break;
        case 1:
            //Be able to add new passwords
            if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
                return UITableViewCellEditingStyleInsert;
            }
            //Delete existing passwords
            return UITableViewCellEditingStyleDelete;
            
            break;
            
        case 2:
            //Permanent information
            [[tableView cellForRowAtIndexPath:indexPath] setEditing:NO];
            
            return UITableViewCellEditingStyleNone;
            break;
            
        default:
            break;
    }
    
    return UITableViewCellEditingStyleDelete;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    /*Sections
     1.==========
     Hostname
     Model
     2.==========
     Passwords(x)
     ++New Password
     3.==========
     Location
     iOS
     MAC
     Vendor
    */
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int rows;
    switch (section) {
        case 0:
            rows = 2;
            break;
        case 1:
            //add an extra blank row for additions.
            rows = [[self.device passwords] count];
            rows += 1;
            break;
        case 2:
            rows = 4;
            break;
        default:
            rows = 0;
            break;
    }
    return rows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *label = [[UILabel alloc] init];
    NSString *title;

    //Create a custom gradient view for the header
    switch (section) {
        case 0:
            title = [NSString stringWithFormat:@"   Required"];
            break;
        case 1:
            title = [NSString stringWithFormat:@"   Passwords"];
            break;
        case 2:
            title = [NSString stringWithFormat:@"   Additional Info"];
            break;
            
        default:
            break;
    }
    
    [label setText:title];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setTextColor:[UIColor whiteColor]];
    [label setShadowColor:[UIColor blackColor]];
    //[label setShadowOffset:CGSizeMake(0, -1)];
    [label setBackgroundColor:color4];
    return label;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;    if (cell == nil) {
        //NSLog(@"cell is nil.");
        [[NSBundle mainBundle] loadNibNamed:@"DeviceVCCell" owner:self options:nil];
        cell = tvCell;
        tvCell = nil;
    } else {
        //NSLog(@"cell is not nil.");
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    //[self.view setBackgroundColor:color4];
    return cell;
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UITextField *textField = (UITextField *)[cell viewWithTag:textFieldTAG];
    [textField setDelegate:self];
    [textField setBackgroundColor:[UIColor whiteColor]];
    UILabel *label = (UILabel *)[cell viewWithTag:labelTAG];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                //Hostname
                [textField setText:[device hostname]];
                [textField setPlaceholder:@"Hostname"];
                break;
            case 1:
                //Location
                [textField setText:[device model]];
                [textField setPlaceholder:@"Model"];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        [textField setEnabled:NO];
        [textField setHidden:YES];
        //Passwords
        NSSet *passwords = [device passwords];
        /*
         Fill the title for each cell only if
         a. there is a valid password
         b. it isn't the last cell.
         */
        if (passwords.count > 0 && indexPath.row < passwords.count) {
            Password *password = [[passwords allObjects] objectAtIndex:indexPath.row];
            [label setText:[password title]];
            [label setTextColor:[UIColor blackColor]];
        }
        
        
        //Password
        if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
            
            [label setTextColor:[UIColor colorWithRed:254.0/255.0 green:180.0/255.0 blue:128.0/255.0 alpha:1]];
            [label setText:@"Add Password"];
        }

    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                //Model
                [textField setText:[device location]];
                [textField setPlaceholder:@"Location"];
                break;
            case 1:
                //iOS
                [textField setText:[device ios]];
                [textField setPlaceholder:@"IOS Version"];
                break;
            case 2:
                //MAC
                [textField setText:[device mac]];
                [textField setPlaceholder:@"MAC Address"];
                break;
            case 3:
                //Vendor
                [textField setText:[device vendor]];
                [textField setPlaceholder:@"Vendor"];
                break;
            default:
                break;
        }
                
    }
  
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];   
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    //Hostname
                    [device setHostname:textField.text];
                    break;
                case 1:
                    //Model
                    [device setModel:textField.text];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            //Passwords have an edit menu. Can't change text for the passwords
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    //Location
                    [device setLocation:textField.text];
                    break;
                case 1:
                    //iOS
                    [device setIos:textField.text];
                    break;
                case 2:
                    //MAC
                    [device setMac:textField.text];
                    break;
                case 3:
                    //Vendor
                    [device setVendor:textField.text];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        //Only 50 characters
    if ([textField.text length] > 128) {
        return NO;
    }
    
    //validate the mac address
    switch (indexPath.section) {
            //Section 2
        case 2:
            switch (indexPath.row) {
                    //Row 2
                case 2:
                    //MAC
                    if (![ActionClass isValidMACString:string]) {
                        return NO;
                    }
                    //Example MAC
                    //11:22:33:44:55:66
                    if ([textField.text length] + range.length >= 17 && range.location == 0) {
                        return NO;
                    }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return YES;
}

#pragma mark - Variable Initialization

#pragma mark - Custom Implementation

-(void)resignTextFieldFirstResponder {
    
    int sections = [self.tableView numberOfSections];
    //int r = [self.tableView numberOfRowsInSection:s];
    
    for (int section = 0; section < sections; section++) {
        //skip section 1
        if (section != 1) {
            int rows = [self.tableView numberOfRowsInSection:section];
            for (int row = 0; row < rows; row++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UITextField *textField = (UITextField *)[cell viewWithTag:textFieldTAG];
                if ([textField isFirstResponder]) {
                    //NSLog(@"Found a responder!! Resigning it!");
                    [textField resignFirstResponder];
                }
            }
        }
        
    }
    
   
}
@end
