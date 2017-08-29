//
//  DeviceViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/3/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Device.h"

#import "Password.h"

@interface DeviceViewController : UITableViewController <UITextFieldDelegate, UITableViewDelegate> {
    UITableViewCell *tvCell;
}

@property (nonatomic, retain) Device *device;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;


-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)resignTextFieldFirstResponder;
@end
