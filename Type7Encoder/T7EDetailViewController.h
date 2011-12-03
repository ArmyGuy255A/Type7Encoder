//
//  T7EDetailViewController.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 WO1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface T7EDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
