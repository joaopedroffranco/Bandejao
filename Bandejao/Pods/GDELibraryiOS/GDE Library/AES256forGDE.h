//
//  NSData+AES256.h
//
//  Created by Kaz Yoshikawa on 11/06/26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AES256forGDE : NSObject

+ (NSData *)encrypt:(NSData*)data key:(NSData *)key iv:(NSData*)iv;
+ (NSData *)decrypt:(NSData*)data key:(NSData *)key iv:(NSData*)iv;

@end
