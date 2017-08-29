//
//  PasswordViewController.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/5/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "PasswordViewController.h"
#import "decrypt.h"
#import "Password.h"

@implementation PasswordViewController

@synthesize pickerDataSource = __pickerDataSource;
@synthesize password = __password;
@synthesize titlePicker = __titlePicker;
@synthesize device;
@synthesize cipherTextField, titleTextField;
@synthesize plainLabel, descLabel1;
@synthesize masterPopoverController;


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControls];
    [self.view setBackgroundColor:color4];
    [self setTitle:NSLocalizedString(@"Decoder", @"Decoder")];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}
-(void)viewWillDisappear:(BOOL)animated {
    
    if (!self.device) {
        [[AppDelegate managedObjectContext] deleteObject:self.password];
    }
    
    //resign the responders
    if ([self.cipherTextField isFirstResponder]) {
        [self.password setPasswd:self.cipherTextField.text];
        [self.cipherTextField resignFirstResponder];
    } else if ([self.titleTextField isFirstResponder]) {
        [self.password setTitle:self.titleTextField.text];
        [self.titleTextField resignFirstResponder];
    }
    
    //if password is nil, delete the password.
    if (self.password.passwd == nil || [self.password.passwd isEqualToString:@""]) {
        [[AppDelegate managedObjectContext] deleteObject:self.password];
        return;
    }
    
    if (self.password.title == nil || [self.password.title isEqualToString:@""]) {
        NSString *title = [NSString stringWithFormat:@"Password%i", [self.device.passwords count]];
        [self.password setTitle:title];
    }
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

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"shouldReturn");
    if (textField == self.cipherTextField) {
        if ([textField.text length] < 4) {
            [self setPlaceholderString:self.plainLabel];
            [self.password setPasswd:@""];
        }
        bool ctOdd = [textField.text length] % 2;
        if (!ctOdd) {
            [self updatePlainLabel:textField.text];
        }
    }
   [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //NSLog(@"shouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"didEndEditing");
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /*
     if Range.length = 0, that means there was a deletion.
     Its safe to say that range.length is equal to the number of characters that were deleted by the user. string.length is equal to the number of characters that were typed by the user.
     */
    //Only 128 characters
    if ([textField.text length] > 255) {
        return NO;
    }
    if (textField == self.cipherTextField) {
    
        int i = [string length];
        int d = range.length;

        //ensure only numbers and letters are used. But only letters A through F.
        if (![ActionClass isValidHexString:string]) {
            return NO;
        }
        
        //Ensure the plainLabel is reset when there isn't enough characters.
        if (([textField.text length] + i < 4 && i > 0 )||
            ([textField.text length] <= 4 && d > 0)) {
            [self setPlaceholderString:self.plainLabel];
            [self.password setPasswd:@""];
            return YES;
        }
        
        NSMutableString *ct = [textField.text mutableCopy];
        
        if (i > 0) {
            //User typed or pasted something
            int y = [textField.text length] + i;
            bool ctEven = y % 2;
            ctEven = !ctEven;
            //if ct Characters are an even number, perform the update
            if (ctEven) {
                [ct appendString:string];
                [self updatePlainLabel:ct];
            }
            
        } else if (d > 0){
            //User deleted something
            int y = [textField.text length] - d;
            bool ctEven = y % 2;
            ctEven = !ctEven;
            //if ct Characters are an even number, perform the update
            if (ctEven) {
                int t = [textField.text length] - d;
                NSRange delRange = NSMakeRange(t, d);
                [ct replaceCharactersInRange:delRange withString:@""];
                [self updatePlainLabel:ct];
            }
        }
        
        [self.password setPasswd:ct];
        //NSLog(@"Password CT: %@", [self.password passwd]);
    } else if (textField == self.titleTextField){
        //This method is used for real time updates to the data model. Pretty neat :)
        int i = [string length];
        int d = range.length;
        
        NSMutableString *title = [textField.text mutableCopy];
        
        if (i > 0) {
            //something entered
            [title appendString:string];
        } else if (d > 0) {
            //something deleted
            int t = [textField.text length] - d;
            NSRange delRange = NSMakeRange(t, d);
            [title replaceCharactersInRange:delRange withString:@""];
        }
        
        [self.password setTitle:title];
    }
    return YES;
}

#pragma mark - UIPicker View Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    title = [[self.pickerDataSource objectAtIndex:component] objectAtIndex:row];
    
    return title;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    float x = 75.0;
    float sw = self.view.frame.size.width;
    switch (component) {
        case 0:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                x = sw - (sw * 0.01);
            } else {
                x = 260;
            }
            
            break;
        case 1:
            x = 70;
            break;
        case 2:
            x = 55;
            break;
        case 3:
            x = 40;
            break;
            
        default:
            break;
    }
    
    return x;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    float x = 30;
    
    return x;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}
#pragma mark - UIPicker View Data Source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    int x = [self.pickerDataSource count];
    
    return x;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    int x = [[self.pickerDataSource objectAtIndex:component] count];
    
    return x;
}

#pragma mark - UIActionSheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        int component = 0;
        NSString *title = [[self.pickerDataSource objectAtIndex:component] objectAtIndex:[self.titlePicker selectedRowInComponent:component]];
        [self.titleTextField setText:title];
        [self.password setTitle:title];
    } else if (buttonIndex == 1) {
        
    } else {
        
    }

}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet {
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Devices", @"Devices");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
  
}

#pragma mark - Custom Implementation
-(Password *)password {
    if (__password) {
        return __password;
    }
    
    [self setPassword:[ActionClass addNewPassword:device]];
    __password = self.password;
    
    return __password;
}

-(UIPickerView *)titlePicker {
    if (__titlePicker) {
        return __titlePicker;
    }
    
    __titlePicker = [[UIPickerView alloc] init];
    [__titlePicker setDelegate:self];
    [__titlePicker setDataSource:self];
    [__titlePicker setShowsSelectionIndicator:YES];
    
    [self setTitlePicker:__titlePicker];
    
    return __titlePicker;
}

-(NSMutableArray *)pickerDataSource {
    
    if (__pickerDataSource) {
        return __pickerDataSource;
    }
    __pickerDataSource = [[NSMutableArray alloc] init];
    
    //get all custom titles
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Password"
    inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
    ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    //filter duplicates
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSError *error = nil;
    NSMutableArray *fetchedObjects = [[[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (fetchedObjects == nil) {
        [fetchedObjects addObject:[NSString stringWithFormat:@"Line CON 0"]];
    }
    //add the strings
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    NSEnumerator *e = [fetchedObjects objectEnumerator];
    Password *p;
    while (p = [e nextObject]) {
        if (![strings containsObject:[p title]] && [p title]) {
            [strings addObject:[p title]];
        }
    }
    
    
    [__pickerDataSource insertObject:[strings sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] atIndex:0];
    [self setPickerDataSource:__pickerDataSource];
    
    return __pickerDataSource;
}
-(void)initControls {
    //Sepearate each element by 6% of pixels with a margin of 4%
    float t = 0.04;
    float s = 0.0;
    float m = 0.04;
    float h = 30;
    
    self.descLabel1 = [[UILabel alloc] init];
    self.plainLabel = [[UILabel alloc] init];
    self.cipherTextField = [[UITextField alloc] init];
    self.titleTextField = [[UITextField alloc] init];
    
    
    
    NSArray *objects = [NSArray arrayWithObjects:self.descLabel1, self.cipherTextField, self.plainLabel, self.titleTextField, nil];
    
    //set autosizing and a few other properties
    NSEnumerator *e = [objects objectEnumerator];
    UIView *subView;
    while (subView = [e nextObject]) {
        
        s += m;
        CGRect frame = self.view.frame;
        CGRect subViewFrame = CGRectMake(frame.size.width * m, (frame.size.width * s), frame.size.width - frame.size.width * (m * 2), h);
        [subView setFrame:subViewFrame];
        s += (t + m);
        [subView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
        
        //Granular control
        if ([subView isKindOfClass:[UILabel class]]) {
            //Labels
            UILabel *label = (UILabel *)subView;
            [label setFont:[UIFont systemFontOfSize:18]];
            [label setAdjustsFontSizeToFitWidth:YES];
            [label setNumberOfLines:2];
            [label setTextColor:[UIColor blackColor]];
            [label setTextAlignment:UITextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            
        } else if ([subView isKindOfClass:[UITextField class]]) {
            //TextFields
            UITextField *textField = (UITextField *)subView;
            [textField setBorderStyle:UITextBorderStyleRoundedRect];
            [textField setBackgroundColor:[UIColor whiteColor]];
            [textField setFont:[UIFont systemFontOfSize:20]];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
            [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [textField setDelegate:self];
            
            if (textField == self.titleTextField) {
                //Add the rightView
                float x = textField.frame.size.height * .7;
                float p = x / 2;
                NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"textFieldRightImage" ofType:@"png"];
                UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
                UIButton *rightViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, p, x, x)];
                                                                                       
                //UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, x-8, x-8)];
                //[rightView setImage:img];
                [rightViewButton setBackgroundImage:img forState:UIControlStateNormal];
                [rightViewButton setBackgroundColor:[UIColor clearColor]];
                [rightViewButton addTarget:self action:@selector(showTitles:) forControlEvents:UIControlEventTouchUpInside];
                
                [textField setRightViewMode:UITextFieldViewModeAlways];
                [textField setRightView:rightViewButton];
                [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
                
            }
            
        }
        
        [self.view addSubview:subView];
    }
    
    [self.descLabel1 setText:@"Enter the Type 7 Password Below"];
    [self setPlaceholderString:self.plainLabel];
    
    [self.cipherTextField setText:[self.password passwd]];
    [self.cipherTextField setPlaceholder:@"Ex: 02050D480809"];
    [self.titleTextField setText:[self.password title]];
    [self.titleTextField setPlaceholder:@"Description"];
    
    if (![self.cipherTextField.text isEqualToString:@""]) {
        [self updatePlainLabel:self.cipherTextField.text];
    }
    

}

-(void)updatePlainLabel:(NSString *)ct {
    NSString *pt = [decrypt type7:ct];
    NSString *error;
    NSScanner *scanner = [NSScanner scannerWithString:pt];
    [scanner scanUpToString:@"ERROR:" intoString:&error];
    if ([error isEqualToString:@"ERROR:"] || error == nil) {
        NSLog(@"%@",pt);
        [self setPlaceholderString:self.plainLabel];
    } else {
        [self.plainLabel setText:pt];
    }
}



-(void)setPlaceholderString:(UILabel *)label {
    if (!label || ![label isKindOfClass:[UILabel class]]) {
        return;
    }
    
    [label setText:@"-------------------------"];
    
}

-(void)removeSubviews{
    UIButton *theBlocker = (UIButton *)[self.view viewWithTag:69];
    [theBlocker removeFromSuperview];
    
    UIActionSheet *actionSheet = (UIActionSheet *)[self.view viewWithTag:79];
    [actionSheet removeFromSuperview];
}

-(void)showTitles:(id)sender {
    __pickerDataSource = nil;
    __titlePicker = nil;
    
    //Resign the first responder of the textField
    if ([self.titleTextField isFirstResponder]) {
        [self.titleTextField resignFirstResponder];
    }
    
    
    

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Set Title", nil];
    [actionSheet addSubview:self.titlePicker];    
    [actionSheet setTag:79];
    [actionSheet setBackgroundColor:[UIColor darkGrayColor]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet setTitle:[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n"]];
    } else {
        //action sheet width = 272
        float w = 272;
        [self.titlePicker setBackgroundColor:[UIColor clearColor]];
        [self.titlePicker setFrame:CGRectMake(1, 2, w - 2, self.titlePicker.frame.size.height)];
        [actionSheet setTitle:[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"]];
    }
       
    [actionSheet showInView:self.view];

}
@end
