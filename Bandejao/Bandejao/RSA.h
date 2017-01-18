//
//  RSA.h
//  teste
//
//  Created by Nicholas Matuzita Mizoguchi on 8/22/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject {
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}
- (NSData *) encryptWithData:(NSData *)content;
- (NSData *) encryptWithString:(NSString *)content;
- (NSString *) encryptToString:(NSString *)content;
- (NSData *) decryptWithData:(NSData *)content;
@end