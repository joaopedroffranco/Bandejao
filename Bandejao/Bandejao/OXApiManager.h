//
//  OXApiManager.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/24/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts.h>
#import "NFPersistentObject.h"

@interface OXApiManager : NFPersistentObject<NSCoding>

+ (OXApiManager *)sharedManager;
- (BFTask*)loginWithUsername:(NSString*)aUsername andPassword:(NSString*)aPassword;
- (BFTask*)scheduleInfoForStudentWithRA:(NSNumber*)ra;
- (BFTask*)diningMenuForId:(NSNumber*)dinningId;
- (BFTask*)diningMenu;
- (BFTask*)searchWithOfferingId:(NSNumber*)offeringId;
- (BOOL)loggedIn;
- (void)logout;
- (NSNumber*)userRA;
- (BOOL)syncWifiOnly;
- (void)setSyncWifiOnly:(BOOL)config;
@end