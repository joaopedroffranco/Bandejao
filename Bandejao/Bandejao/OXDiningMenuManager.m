//
//  OXDiningMenuManager.m
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/29/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import "OXDiningMenuManager.h"
#import "OXApiDiningMenusResponse.h"
#import "OXApiManager.h"
#define kDiningMenuManagerResponse @"diningManager.response"

@interface OXDiningMenuManager()
@property (nonatomic, strong) NSArray* diningMenus;
@property (nonatomic, assign) int current;
@property (nonatomic, strong) OXApiDiningMenusResponse *response;
@end

@implementation OXDiningMenuManager

/* Singleton implementation */
static OXDiningMenuManager *sharedManager = nil;

+ (OXDiningMenuManager *)sharedManager
{
    if (sharedManager == nil) {
        sharedManager = [[super alloc] init];
    }
    return sharedManager;
}

- (void)setResponse:(OXApiDiningMenusResponse *)response
{
    _response = response;
    
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] init];
    for(OXApiDiningMenuDto *menuDto in response.cardapios) {
        NSMutableArray *currentArray = [mapping objectForKey:menuDto.data];
        if(!currentArray) {
            currentArray = [[NSMutableArray alloc] init];
            [mapping setObject:currentArray forKey:menuDto.data];
        }
        [currentArray addObject:menuDto];
    }
    
    NSArray *menuArrays = [[mapping allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OXApiDiningMenuDto *o1 = [obj1 objectAtIndex:0];
        OXApiDiningMenuDto *o2 = [obj2 objectAtIndex:0];
        return [o1.data compare:o2.data];
    }];
    
    NSMutableArray *menus = [[NSMutableArray alloc] init];

    for(NSArray *array in menuArrays) {
        OXDiningMenu *menu = [[OXDiningMenu alloc] init];
        NSMutableDictionary *menuDict = [[NSMutableDictionary alloc] init];

        for(OXApiDiningMenuDto *menuDto in array) {
            [menuDict setObject:menuDto forKey:menuDto.tipo];
            menu.day = [NSDate dateFromString:menuDto.data];
        }
        
        menu.dayMenus = [NSDictionary dictionaryWithDictionary:menuDict];
        [menus addObject:menu];
    }
    
    self.diningMenus = [NSArray arrayWithArray:menus];
}

- (OXDiningMenu*)currentMenu;
{
    return [self nextMenuFromDate:[NSDate date]];
}

- (OXDiningMenu*)nextMenuFromDate:(NSDate*)aDate;
{
    for(int i = 0; i < [self.diningMenus count]; i++) {
        OXDiningMenu *menu = self.diningMenus[i];

        if([[menu.day dateByAddingTimeInterval:24*3600] compare:aDate] > 0) {
            return menu;
        }
    }
    
    return nil;
}

- (OXDiningMenu*)previousMenuFromDate:(NSDate*)aDate;
{
    for(int i = (int)[self.diningMenus count]-1; i >= 0; i--) {
        OXDiningMenu *menu = self.diningMenus[i];
        if([menu.day compare:aDate] < 0) {
            return menu;
        }
    }
    
    return nil;
}

-(BOOL)loaded
{
    return self.response != nil;
}

- (BFTask*)fetchFromNetwork
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    [[[OXApiManager sharedManager] diningMenu] continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            self.response = task.result;
            [self save];
            [taskSource setResult:@YES];
        } else {
            [taskSource setError:task.error];
        }
        return nil;
    }];
    
    return taskSource.task;
}

#pragma mark - NSCoding methods
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[self.response toJSONString] forKey:kDiningMenuManagerResponse];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *responseString = [decoder decodeObjectForKey:kDiningMenuManagerResponse];
    self.response = [[OXApiDiningMenusResponse alloc] initWithString:responseString error:nil];
    return self;
}
@end
