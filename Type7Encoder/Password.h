//
//  Password.h
//  Type7Decoder
//
//  Created by Phillip Dieppa on 12/10/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Password : NSManagedObject

@property (nonatomic, retain) NSNumber * expanded;
@property (nonatomic, retain) NSString * passwd;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Device *device;

@end
