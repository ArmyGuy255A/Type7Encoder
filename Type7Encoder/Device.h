//
//  Device.h
//  Type7Decoder
//
//  Created by Phillip Dieppa on 12/10/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Password;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSString * ios;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * mac;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * vendor;
@property (nonatomic, retain) NSSet *passwords;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addPasswordsObject:(Password *)value;
- (void)removePasswordsObject:(Password *)value;
- (void)addPasswords:(NSSet *)values;
- (void)removePasswords:(NSSet *)values;

@end
