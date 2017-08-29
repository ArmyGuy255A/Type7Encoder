//
//  decrypt.m
//  Type7Encoder
//
//  Created by Phillip Dieppa on 12/2/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "decrypt.h"

@implementation decrypt
/*
Here is the algorithm:
Example type7 07362E590E1B1C041B1E124C0A2F2E206832752E1A01134D

 The first two numbers indicate the key for the cipher. In this example, 07 equals the 8th item in the key array, or 0x6f. Remember that all arrays start at 0, therefore 0,1,2,3,4,5,6,7 = 8th item in the array. The second two characters in the string represent the first set of cipher characters in the password, or 36. 36 is actually a hexadecimal number the corresponds to a particular ASCII character. Each pair of hexadecimal values must be deciphered with the appropriate key to unmask the clear text password. The deciphering process is as simple as performing an XOR operation between the key and cipher text message. The example below proves this theorem:
 
 0110 1111 = 0x6f = o (key)
 0011 0110 = 0x36 = 6 (ct)
 --------- XOR
 0101 1001 = 0x59 = Y (pt)
*/


char keychain[] = {
    0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41, 0x2c, 0x2e,
    0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c, 0x64, 0x4a, 0x4b, 0x44,
    0x48, 0x53, 0x55, 0x42, 0x73, 0x67, 0x76, 0x63, 0x61, 0x36, 0x39,
    0x38, 0x33, 0x34, 0x6e, 0x63, 0x78, 0x76, 0x39, 0x38, 0x37, 0x33,
    0x32, 0x35, 0x34, 0x6b, 0x3b, 0x66, 0x67, 0x38, 0x37
};

+(NSString *)type7:(NSString *)ct {
     
    if (!ct) {
        NSString *error = [NSString stringWithFormat:@"ERROR: Nil string passed."];
        //NSLog(@"%@", error);
        return error;
    }
    //Lets work with a mutable copy of the original string.
    NSMutableString *t7s = [ct mutableCopy];
    
    //Delete this line for production
    if (!t7s) {
        //Test Strings
        
        NSArray *pwords = [NSArray arrayWithObjects:[NSString stringWithFormat:@"12090404011C03162E"],
         [NSString stringWithFormat:@"095C4F1A0A1218000F"],
         [NSString stringWithFormat:@"02050D480809"],
         [NSString stringWithFormat:@"08351F1B1D431516475E1B54382F"],
         [NSString stringWithFormat:@"07362E590E1B1C041B1E124C0A2F2E206832752E1A01134D"], nil];
        int x = arc4random() % pwords.count;
        
        t7s = [pwords objectAtIndex:x];
    }
    
    
    
    //There needs to be more than 4 characters to be a valid type7 length
    if ([t7s length] < 4) {
        NSString *error = [NSString stringWithFormat:@"ERROR: Not Enough Characters."];
        //NSLog(@"%@", error);
        return error;
    }
    
    //There needs to be an even number of characters to be a valid type7. Perform a modulus 2 on the type 7 string. Even numbers should return 0 while odd numbers return 1.
    bool ctOdd = [t7s length] % 2;
    if (ctOdd) {
        NSString *error = [NSString stringWithFormat:@"ERROR: Invalid number of characters."];
        //NSLog(@"%@", error);
        return error;
    }
    
    // TODO: Might need to find out if there are invalid characters. Going to test many weird characters and see if it crashes.
    
    //Make sure the key index is valid
    int keyIndex = [[t7s substringToIndex:2] intValue];
    if (keyIndex > sizeof(keychain)) {
         NSString *error = [NSString stringWithFormat:@"ERROR: Invalid type7 string."];
        //NSLog(@"%@", error);
        return error;
    }
    
    //Remove the key from the string
    [t7s deleteCharactersInRange:NSMakeRange(0,2)];
    
    //Instantiate a plain text string to concatenate a password
    NSMutableString *pt = [NSMutableString stringWithString:@""];
    
    //Start iterating through the string.
    while ([t7s length] > 0) {
        //get the first two hex values.
        NSString *ctString1 = [NSString stringWithFormat:@"0x%@",[t7s substringWithRange:NSMakeRange(0, 2)]];
        
        //get the key
        char key = keychain[keyIndex]; 
        
        //Convert the string value to an integer value.
        char c = [decrypt intFromHexString:ctString1];
        
        //Perform an XOR between key and the cipher value
        char p = key ^ c;
         
        //Add the character to the plain text string
        [pt appendString:[decrypt stringFromInt:p]];
        
        //Remove the two characters
        [t7s deleteCharactersInRange:NSMakeRange(0, 2)];
        
        //Cisco decided to increment the key that's used by 1. So, use the next key in the keychain
        keyIndex += 1;
        
        //The Vigenère algorithm will eventually run out of keys. Go to the first key in the keychain and continue with normal operations. This principal is based on a modulus equal to the number of keys in the chain.
        if (keyIndex > sizeof(keychain)) {
            keyIndex = 0;
        }
        
        key = keychain[keyIndex];
        
        
        
    }
    
    return pt;
}

+(int)intFromHexString:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned int result = 0;
    if (![scanner scanHexInt:&result]) {
        NSLog(@"ERROR: getting integer from hexstring: %@", hexString);
        return 0;
    }
    return result;
}

+(NSString *)stringFromInt:(int)integer{
    const unichar x = integer;
    
    NSString *string = [NSString stringWithCharacters:&x length:1];
    
    return string;
}



@end
