//
//  decrypt.h
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface decrypt : NSObject

+(NSString *)type7:(NSString *)ct;

+(int)intFromHexString:(NSString *)hexString;

+(NSString *)stringFromInt:(int)integer;

@end
