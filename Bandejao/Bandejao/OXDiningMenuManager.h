//
//  OXDiningMenuManager.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/29/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import "NFPersistentObject.h"
#import "OXDiningMenu.h"
#import <Bolts.h>

@interface OXDiningMenuManager : NFPersistentObject<NSCoding>
- (OXDiningMenu*)currentMenu;
- (OXDiningMenu*)nextMenuFromDate:(NSDate*)aDate;
- (OXDiningMenu*)previousMenuFromDate:(NSDate*)aDate;
- (BFTask*)fetchFromNetwork;
+ (OXDiningMenuManager *)sharedManager;
@end
