//
//  OXDiningMenu.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/29/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXDiningMenuPeriod) {
    OXDiningMenuPeriodLunch = 1,
    OXDiningMenuPeriodDinner = 2,
};
@interface OXDiningMenu : NSObject
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, strong) NSDictionary *dayMenus;
@end
