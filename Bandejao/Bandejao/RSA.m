#import "RSA.h"

@implementation RSA

- (id)init {
    self = [super init];
    
    if(![self configurePublicKey]) return nil;
    
    return self;
}

- (BOOL)configurePublicKey
{
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"config/public_key"
                                                              ofType:@"der"];
    if (publicKeyPath == nil) {
//        NSLog(@"Can not find pub.der");
        return NO;
    }
    
    NSData *publicKeyFileContent = [NSData dataWithContentsOfFile:publicKeyPath];
    if (publicKeyFileContent == nil) {
//        NSLog(@"Can not read from pub.der");
        return NO;
    }
    
    certificate = SecCertificateCreateWithData(kCFAllocatorDefault, ( __bridge CFDataRef)publicKeyFileContent);
    if (certificate == nil) {
//        NSLog(@"Can not read certificate from pub.der");
        return NO;
    }
    
    policy = SecPolicyCreateBasicX509();
    OSStatus returnCode = SecTrustCreateWithCertificates(certificate, policy, &trust);
    if (returnCode != 0) {
//        NSLog(@"SecTrustCreateWithCertificates fail. Error Code: %d", returnCode);
        return NO;
    }
    
    SecTrustResultType trustResultType;
    returnCode = SecTrustEvaluate(trust, &trustResultType);
    if (returnCode != 0) {
        return NO;
    }
    
    publicKey = SecTrustCopyPublicKey(trust);
    if (publicKey == nil) {
//        NSLog(@"SecTrustCopyPublicKey fail");
        return NO;
    }
    
    maxPlainLen = SecKeyGetBlockSize(publicKey) - 12;
    
    return YES;
}

- (NSData *) encryptWithData:(NSData *)content {
    
    size_t plainLen = [content length];
    if (plainLen > maxPlainLen) {
//        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain
               length:plainLen];
    
    size_t cipherLen = 256; // currently RSA key length is set to 128 bytes
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0) {
//        NSLog(@"SecKeyEncrypt fail. Error Code: %d", returnCode);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

- (NSData *) decryptWithData:(NSData *)content {
    
//    size_t plainLen = [content length];
//    if (plainLen > maxPlainLen) {
//        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
//        return nil;
//    }

    size_t cipherLen = 256; // currently RSA key length is set to 128 bytes
    void *cipher = malloc(cipherLen);
    [content getBytes:cipher
               length:cipherLen];
    void *plain = malloc(2048);
    size_t plainLen = 2048;
    OSStatus returnCode = SecKeyDecrypt(publicKey, kSecPaddingPKCS1, cipher, cipherLen, plain, &plainLen);
    NSData *result = nil;
    if (returnCode != 0) {
//        NSLog(@"SecKeyEncrypt fail. Error Code: %d", returnCode);
    }
    else {
        result = [NSData dataWithBytes:plain
                                length:plainLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

- (NSData *) encryptWithString:(NSString *)content {
    return [self encryptWithData:[content dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *) encryptToString:(NSString *)content {
    NSData *data = [self encryptWithString:content];
    return [self base64forData:data];
}

// convert NSData to NSString
- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)dealloc{
    CFRelease(certificate);
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(publicKey);
}

- (SecKeyRef)getPublicKeyRef {
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"rsaCert" ofType:@"der"];
    NSData *certData = [NSData dataWithContentsOfFile:resourcePath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    SecKeyRef key = NULL;
//    SecTrustRef trust = NULL;
//    SecPolicyRef policy = NULL;
    
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    key = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}

@end