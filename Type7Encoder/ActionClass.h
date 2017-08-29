//
//  ActionClass.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/4/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "Password.h"
#import "DeviceViewController.h"

#define RGBA(r, g, b, a) (UIColor *)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//Saffron Umbrella - Kuler
#define color1 (UIColor *)[UIColor colorWithRed:36.0/255 green:34.0/255.0 blue:31.0/255.0 alpha:1]
#define color2 (UIColor *)[UIColor colorWithRed:54.0/255.0 green:63.0/255.0 blue:69.0/255.0 alpha:1]
#define color3 (UIColor *)[UIColor colorWithRed:75.0/255.0 green:95.0/255.0 blue:109.0/255.0 alpha:1]
#define color4 (UIColor *)[UIColor colorWithRed:94.0/255.0 green:124.0/255.0 blue:136.0/255.0 alpha:1]
#define colorAccent (UIColor *)[UIColor colorWithRed:254.0/255.0 green:180.0/255.0 blue:28.0/255.0 alpha:1]

@interface ActionClass : NSObject
+(Device *)createNewDevice;
+(DeviceViewController *)pushDeviceVC:(Device *)device withTitle:(NSString *)title;
+(Password *)addNewPassword:(Device *)device;
+(void)collapseAllPasswords:(Device *)device;
+(void)deleteOrphanPasswords;
+(BOOL)isValidHexString:(NSString *)string;
+(BOOL)isValidMACString:(NSString *)string;

//Core Data Saving
+(void)saveContext:(NSManagedObjectContext *)context exclusive:(BOOL)exclusive;
+(void)saveContext:(NSManagedObjectContext *)context;
+(NSTimer *)startSaveTimer;
+(void)showCoreDataError;
+(void)undo:(NSManagedObjectContext *)context;
+(void)redo:(NSManagedObjectContext *)context;

@end
