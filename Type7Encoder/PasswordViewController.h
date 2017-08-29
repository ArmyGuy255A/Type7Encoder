//
//  PasswordViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/5/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate>


@property (nonatomic, retain) UITextField *cipherTextField;
@property (nonatomic, retain) UITextField *titleTextField;
//@property (nonatomic, retain) UILabel *cipherLabel;
@property (nonatomic, retain) UILabel *plainLabel;
@property (nonatomic, retain) UILabel *descLabel1;
//@property (nonatomic, retain) UILabel *descLabel2;
@property (nonatomic, retain) UIPickerView *titlePicker;
@property (nonatomic, retain) NSMutableArray *pickerDataSource;

@property (nonatomic, retain) Password *password;

//splitviewcontroller objects
@property (nonatomic, retain) Device *device;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;



-(void)initControls;
-(void)updatePlainLabel:(NSString *)ct;
-(void)setPlaceholderString:(UILabel *)textField;
@end
