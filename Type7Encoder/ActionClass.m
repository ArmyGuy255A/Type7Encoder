//
//  ActionClass.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/4/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "ActionClass.h"

@implementation ActionClass


+(Device *)createNewDevice {
    Device *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:[AppDelegate managedObjectContext]];
    
    //[newDevice setHostname:[NSString stringWithFormat:@"Hostname"]];
    //[newDevice setModel:[NSString stringWithFormat:@"Model"]];
    
    return newDevice;
}

+(DeviceViewController *)pushDeviceVC:(Device *)device withTitle:(NSString *)title{
    DeviceViewController *dvc = [[DeviceViewController alloc] initWithStyle:UITableViewStylePlain];
    
    if (!device) {
        device = [ActionClass createNewDevice];
    }
    
    if (!title) {
        title = [NSString stringWithFormat:@"New Device"];
    }
    
    [dvc setTitle:title];
    [dvc setDevice:device];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //push only one navcon
        UINavigationController *nvc = (UINavigationController *)[[AppDelegate window] rootViewController];
        [nvc pushViewController:dvc animated:YES];
        
    } else {
        //push to masterviewcontroller
        UINavigationController *nvc = (UINavigationController *)[[[AppDelegate splitViewController] viewControllers] objectAtIndex:0];
        [nvc pushViewController:dvc animated:YES];        
    }
    
    return dvc;
}

+(Password *)addNewPassword:(Device *)device {
    
    Password *password = [NSEntityDescription insertNewObjectForEntityForName:@"Password" inManagedObjectContext:[AppDelegate managedObjectContext]];
    
    if (device) {
        [device addPasswordsObject:password];
    }
    
    //Return a password without a device. That's fine.

    return password;
}

+(void)collapseAllPasswords:(Device *)device {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Password"
    inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expanded=%@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || fetchedObjects.count == 0) {
        //no objects to collapse. Quit.
        //NSLog(@"No objects to collapse.");
        return;
    } else {
       // NSLog(@"Found %i expanded objects. Collapsing objects...", fetchedObjects.count);
    }
    
    NSEnumerator *e = [fetchedObjects objectEnumerator];
    Password *password;
    while (password = [e nextObject]) {
        [password setExpanded:[NSNumber numberWithBool:NO]];
    }
    
    //NSLog(@"Finished collapsing objects.");

}

+(void)deleteOrphanPasswords {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Password" inManagedObjectContext:[AppDelegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *noDevice = [NSPredicate predicateWithFormat:@"device=nil"];
    [fetchRequest setPredicate:noDevice];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[AppDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || fetchedObjects.count == 0) {
        //This is a good thing!
        //NSLog(@"No Passwords to check.");
        return;
    }
    
    //Delete the orphanded records
    //NSLog(@"Checking for orphan paswords.");
    NSEnumerator *e = [fetchedObjects objectEnumerator];
    Password *p;
    while (p = [e nextObject]) {
        //NSLog(@"\n\nPasswd: %@ \nTitle: %@\nDevice: %@", [p passwd], [p title], [[[p device] objectID] description]);
        //The device should already be null. Perform another check, just in case!
        if (![p device]) {
            //NSLog(@"Deleting orphan password!");
            [[AppDelegate managedObjectContext] deleteObject:p];
        }
    }

   
}

+(BOOL)isValidHexString:(NSString *)string {
    if (string == nil) {
        return NO;
    }
    if (string.length == 0) {
        return YES;
    }
    
    NSString *error;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *validCharSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"1234567890ABCDEFabcdef"]];
    return [scanner scanCharactersFromSet:validCharSet intoString:&error];
    
}

+(BOOL)isValidMACString:(NSString *)string {
    if (string == nil) {
        return NO;
    }
    if (string.length == 0) {
        return YES;
    }
    
    NSString *error;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *validCharSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"1234567890ABCDEFabcdef:"]];
    return [scanner scanCharactersFromSet:validCharSet intoString:&error];
    
}

#pragma mark - Core Data Saving

+(void)saveContext:(NSManagedObjectContext *)context exclusive:(BOOL)exclusive{
    NSError *error = nil;
    if (context != nil && [context hasChanges]) {
        //handle exclusive saves and end
        if (exclusive) {
            if ([context hasChanges] && ![context save:&error]) {
                //Changes were not saved.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ActionClass showCoreDataError];
                //Attempt to undo any changes that were made
                [ActionClass undo:context];
                //try to save!
                [ActionClass saveContext:context];
            }
            //end the routine
            NSLog(@"Context Saved Exclusively");
            return;
        } else {
            [ActionClass saveContext:context];
        }
    }
}

+(void)saveContext:(NSManagedObjectContext *)context{
    NSManagedObjectContext *moc;
    if ([[context class] isSubclassOfClass:[NSTimer class]]) {
        //Since the timer is triggering, that means there is a change.
        NSLog(@"Timer Save Attempt.");
        NSDictionary *userInfo = [context userInfo];
        moc = [userInfo objectForKey:@"moc"];
        //[ActionClass saveContext:moc exclusive:YES];
        //return;
    } else {
        moc = context;
    }
    NSError *error = nil;
    if (moc != nil && [moc hasChanges]) {
        
        NSSet *deletedObjects = [moc deletedObjects];
        NSSet *insertedObjects = [moc insertedObjects];
        NSSet *changedObjects = [moc updatedObjects];
        int t = 5;
        int x = [deletedObjects count];
        int y = [insertedObjects count];
        int z = [changedObjects count];
        int total = x + y + z;
        //New save strategy. When there are a certain amount of CUD entries, perform the operation. The 'total' only serves as an overarching strategy to save if there is a culmination of CUD's that do not meet their maximums.
        if (x > t * 2 || y > t * 2 || z > t * 5|| total > (t * 6)) {
            //Proceed with save
            if (![moc save:&error]) {
                //Changes were not saved.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ActionClass showCoreDataError];
                //Attempt to undo any changes that were made
                [ActionClass undo:moc];
                //try to save!
                [ActionClass saveContext:moc];
            }
            NSLog(@"Context Saved, %i changes", total);
        } else {
            NSLog(@"Not enough changes to save");
        }
        
    } else {
        NSLog(@"No changes to save");
    }
}

+(NSTimer *)startSaveTimer {
    //The save timer starts when the persistent store is loaded and returned
    NSTimer *saveTimer = [AppDelegate saveTimer];
    //NSLog(@"Checking if AppDelegate has a timer...");
    if (saveTimer) {
        //NSLog(@"Yes\nChecking if timer is valid...");
        if ([saveTimer isValid]) {
            //NSLog(@"Yes\nInvalidating Timer...");
            [saveTimer invalidate];
        } else {
            //NSLog(@"NO\nRemoving timer from AppDelegate...");
            saveTimer = nil;
        }
    } else {
       //NSLog(@"No");
    }
    NSManagedObjectContext *context = [AppDelegate managedObjectContext];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:context, @"moc", nil];
    //NSLog(@"Starting saveTimer");
    saveTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(saveContext:) userInfo:userInfo repeats:NO];
    [AppDelegate setSaveTimer:saveTimer];
    return saveTimer;
}

+(void)showCoreDataError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Type7Encoder had trouble processing the change.\nAttempting to undo the previous action.\nIf this error persists, restart the app." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

+(void)undo:(NSManagedObjectContext *)context {
    [[context undoManager] undo];
}
+(void)redo:(NSManagedObjectContext *)context {
    [[context undoManager] redo];
}

@end
