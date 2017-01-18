//
//  NSData+AES256.h
//
//  Created by Kaz Yoshikawa on 11/06/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSData *)key iv:(NSData*)iv;
- (NSData *)AES256DecryptWithKey:(NSData *)key iv:(NSData*)iv;

@end