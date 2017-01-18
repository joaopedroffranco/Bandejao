//
//  OXApiManager.m
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/24/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import "OXApiManager.h"
#import "NSData+Base64.h"
#import "NSData+AES256.h"
#import "RSA.h"
#import "OXApiScheduleResponse.h"
#import "OXApiDiningMenuResponse.h"
#import "OXApiDiningMenusResponse.h"
#import "OXApiSearchResponse.h"
#import <AFNetworking.h>
#import "Reachability.h"

#import "OXScheduleManager.h"
#import "OXDiningMenuManager.h"

#define kGDEAuthAddress @"https://grade.daconline.unicamp.br/api/auth.php"
#define kGDECalendarAddress @"https://grade.daconline.unicamp.br/api/horario.php"
#define kGDEDiningMenuAddress @"https://grade.daconline.unicamp.br/api/cardapio.php"
#define kGDESearchEngineAddress @"https://grade.daconline.unicamp.br/api/busca.php"
#define kSymmetricKey @"apiManager-symmetricKey"
#define kCode @"apiManager-code"
#define kSid @"apiManager-sid"
#define kUserRA @"apiManager-RA"
#define kSyncWifiOnly @"apiManager-SyncWifiOnly"

@interface OXApiManager()
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSNumber *userRA;
@property (nonatomic,strong) NSData *symmetricKey;
@property (nonatomic,assign) BOOL syncWifiOnly;
@end

@implementation OXApiManager

/* Singleton implementation */
static OXApiManager *sharedManager = nil;

+ (OXApiManager *)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

- (BFTask*)loginWithUsername:(NSString*)aUsername andPassword:(NSString*)aPassword
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];

    /*************************/
    /* ---- FIRST PHASE ---- */
    /*************************/
    NSData *iv = [OXApiManager random128IV];
    _symmetricKey = [OXApiManager random256BitAESKey];
    
    // Encrypt login info for request with RSA
    RSA *rsa = [[RSA alloc] init];
    NSString *loginInfoEncrypted = [rsa encryptToString:[NSString stringWithFormat:@"{ \"login\": \"%@\", \"senha\": \"%@\", \"iv\": \"%@\", \"chave\": \"%@\" }", aUsername, aPassword, [iv base64EncodedString], [self.symmetricKey base64EncodedString]]];
    
    // Prepare request. Remove newlines if needed
    NSString *requestInfo = [[NSString stringWithFormat:@"{ \"app\" : \"ios\", \"code\" : null, \"dados\" : \"%@\" }", loginInfoEncrypted] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    // Prepare Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDEAuthAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[requestInfo dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // responseObject data comes in UTF8. The string is a base64 rep of the data
        NSData *responseDataIn64baseRep = responseObject;
        NSString *responseInBase64string = [[NSString alloc] initWithData:responseDataIn64baseRep encoding:NSUTF8StringEncoding];
        
        // Decrypt using RSA public key
        NSData *decryptedData = [rsa decryptWithData:[NSData dataFromBase64String:responseInBase64string]];
        NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
        
        // Get response as dictionary
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        NSString *rand = responseDict[@"rand"];
        NSString *code = responseDict[@"code"];
        
        /**************************/
        /* ---- SECOND PHASE ---- */
        /**************************/
        
        // Prepare request encrypted with AES-256
        NSString *secondPhaseInfo = [NSString stringWithFormat:@"{\"rand\": \"%@\"}", rand];
        NSData *secondPhaseEncryptedData = [[secondPhaseInfo dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:_symmetricKey iv:iv];
        
        // Prepare request wrapper
        NSString *secondPhaseEncryptedString = [secondPhaseEncryptedData base64EncodedString];
        NSString *secondPhaseRequest = [NSString stringWithFormat:@"{\"app\": \"ios\", \"code\": \"%@\", \"dados\":\"%@\"}", code, secondPhaseEncryptedString];
        
        // Prepare new AFNetworking request
        NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDEAuthAddress]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        [request2 setHTTPMethod:@"POST"];
        [request2 setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
        [request2 setHTTPBody:[secondPhaseRequest dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperation *op2 = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
        op2.responseSerializer = [AFHTTPResponseSerializer serializer];
        [op2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *responseDict = [self dictionaryFromAES256ResponseData:responseObject iv:iv];

            if([responseDict[@"resultado"] isEqual:@1]) {
                _sid = responseDict[@"sid"];
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                self.userRA = [f numberFromString:responseDict[@"Usuario"][@"Aluno"][@"ra"]];
                [self save];
                
                // Verify hash/etc.
                [[self fetchAll] continueWithBlock:^id(BFTask *task) {
                    if(!task.error)
                        [taskSource setResult:@YES];
                    else
                        [taskSource setError:task.error];
                    return nil;
                }];
                
            } else {
                // Set error correctly
                [taskSource setError:[[NSError alloc] init]];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [taskSource setError:error];
        }];
        [op2 start];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [taskSource setError:error];
    }];
    
    [op start];
    
    return taskSource.task;
}

-(BFTask*)scheduleInfoForStudentWithRA:(NSNumber*)ra
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    if(![self canPerformNetworking]) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [taskSource setError:[[NSError alloc] init]];
        });
        return taskSource.task;
    }
    
    // Encrypt wih AES-256
    NSData *iv = [OXApiManager random128IV];
    NSData *dataToEncrypt = [[NSString stringWithFormat:@"{ \"tipo\": \"aluno\", \"id\": %@, \"periodo\": %d }",ra,[[NSDate date] periodAndYear]] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptedData =[dataToEncrypt AES256EncryptWithKey:self.symmetricKey iv:iv];
    
    // Prepare Wrapper
    NSString *requestInfo = [NSString stringWithFormat:@"{\"sid\": \"%@\", \"iv\":\"%@\", \"dados\": \"%@\" }", self.sid, [iv base64EncodedString], [encryptedData base64EncodedStringWithOptions:0]];
    
    // Prepare AFNetworking Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDECalendarAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[requestInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""]dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [self dictionaryFromAES256ResponseData:responseObject iv:iv];
        NSError *err;
        
        OXApiScheduleResponse* response = [[OXApiScheduleResponse alloc] initWithDictionary:dict error:&err];
        [taskSource setResult:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [taskSource setError:error];
    }];
    [op start];
    return taskSource.task;
}

-(BFTask*)diningMenuForId:(NSNumber*)dinningId
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    if(![self canPerformNetworking]) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [taskSource setError:[[NSError alloc] init]];
        });
        return taskSource.task;
    }
    
    // Encrypt wih AES-256
    NSData *iv = [OXApiManager random128IV];
    NSData *dataToEncrypt = [[NSString stringWithFormat:@"{ \"id\": %@ }", dinningId] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptedData =[dataToEncrypt AES256EncryptWithKey:self.symmetricKey iv:iv];
    
    // Prepare Wrapper
    NSString *requestInfo = [NSString stringWithFormat:@"{\"sid\": \"%@\", \"iv\":\"%@\", \"dados\": \"%@\" }", self.sid, [iv base64EncodedString], [encryptedData base64EncodedStringWithOptions:0]];
    
    // Prepare AFNetworking Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDEDiningMenuAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[requestInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""]dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [self dictionaryFromAES256ResponseData:responseObject iv:iv];
        NSError *err;
        
        OXApiDiningMenuResponse* response = [[OXApiDiningMenuResponse alloc] initWithDictionary:dict error:&err];
        [taskSource setResult:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [taskSource setError:error];
    }];
    [op start];
    return taskSource.task;
}

-(BFTask*)diningMenu
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    if(![self canPerformNetworking]) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [taskSource setError:[[NSError alloc] init]];
        });
        return taskSource.task;
    }
    
    // Encrypt wih AES-256
    NSData *iv = [OXApiManager random128IV];
    
    // Prepare Wrapper
    NSString *requestInfo = [NSString stringWithFormat:@"{\"sid\": \"%@\", \"iv\":\"%@\", \"dados\": {} }", self.sid, [iv base64EncodedString]];
    
    // Prepare AFNetworking Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDEDiningMenuAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[requestInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""]dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [self dictionaryFromAES256ResponseData:responseObject iv:iv];
        NSError *err;
        
        OXApiDiningMenusResponse* response = [[OXApiDiningMenusResponse alloc] initWithDictionary:dict error:&err];
        [taskSource setResult:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [taskSource setError:error];
    }];
    [op start];
    return taskSource.task;
}

- (BFTask*)searchWithOfferingId:(NSNumber*)offeringId
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"alunos",@"tipo",
                          offeringId, @"id_oferecimento", nil];
    return [self searchWithArgs:dict];
}

-(BFTask*)searchWithArgs:(NSDictionary*)args
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    if(![self canPerformNetworking]) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [taskSource setError:[[NSError alloc] init]];
        });
        return taskSource.task;
    }
    
    // Encrypt wih AES-256
    NSData *iv = [OXApiManager random128IV];
    
    NSData *dataToEncrypt = [self jsonDataFromDictionary:args];
    
    NSData *encryptedData =[dataToEncrypt AES256EncryptWithKey:self.symmetricKey iv:iv];
    
    // Prepare Wrapper
    NSString *requestInfo = [NSString stringWithFormat:@"{\"sid\": \"%@\", \"iv\":\"%@\", \"dados\": \"%@\" }", self.sid, [iv base64EncodedString], [encryptedData base64EncodedStringWithOptions:0]];
    
    // Prepare AFNetworking Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kGDESearchEngineAddress]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[requestInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""]dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [self dictionaryFromAES256ResponseData:responseObject iv:iv];
        NSError *err;
        
        OXApiSearchResponse* response = [[OXApiSearchResponse alloc] initWithDictionary:dict error:&err];
        [taskSource setResult:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [taskSource setError:error];
    }];
    [op start];
    return taskSource.task;
}


- (BOOL)loggedIn;
{
    return self.sid != nil;
}

- (void)logout;
{
    [[OXScheduleManager sharedManager] reset];
    
    self.sid = nil;
    self.userRA = nil;
    self.syncWifiOnly = NO;
    [self save];
}

- (BOOL) canPerformNetworking
{
    if([self syncWifiOnly] && ![self wifiAvailable]) return false;
    return true;
}

- (BFTask*) fetchAll
{
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    [tasks addObject:[[OXScheduleManager sharedManager] fetchFromNetwork]];
    [tasks addObject:[[OXDiningMenuManager sharedManager] fetchFromNetwork]];
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BOOL)wifiAvailable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
//    if(status == NotReachable)
//    {
//        //No internet
//    }
//    else
    if (status == ReachableViaWiFi)
    {
        //WiFi
        return true;
    }
//    else if (status == ReachableViaWWAN)
//    {
//        //3G
//    }
    
    return NO;
}

#pragma mark - JSON methods
- (NSData*)jsonDataFromDictionary:(NSDictionary*)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        return jsonData;
    }
    
    return nil;
}
#pragma mark - Cryptography helper methods
- (NSDictionary*)dictionaryFromAES256ResponseData:(NSData*)responseData iv:(NSData*)iv
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData *encodedData = [NSData dataFromBase64String:responseString];
    NSData *decodedData = [encodedData AES256DecryptWithKey:self.symmetricKey iv:iv];
    return [NSJSONSerialization JSONObjectWithData:decodedData options:kNilOptions error:nil];
}

#pragma mark - Random byte generators
+ (NSData *)random256BitAESKey {
    unsigned char buf[32];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

+ (NSData *)random128IV {
    unsigned char buf[16];
    arc4random_buf(buf, sizeof(buf));
    return [NSData dataWithBytes:buf length:sizeof(buf)];
}

#pragma mark - NSCoding methods
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.sid forKey:kSid];
    [encoder encodeObject:self.symmetricKey forKey:kSymmetricKey];
    [encoder encodeObject:self.userRA forKey:kUserRA];
    [encoder encodeBool:self.syncWifiOnly forKey:kSyncWifiOnly];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.sid = [decoder decodeObjectForKey:kSid];
    self.symmetricKey = [decoder decodeObjectForKey:kSymmetricKey];
    self.userRA = [decoder decodeObjectForKey:kUserRA];
    self.syncWifiOnly = [decoder decodeBoolForKey:kSyncWifiOnly];
    return self;
}

@end
