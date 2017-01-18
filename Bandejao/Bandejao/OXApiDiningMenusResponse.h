//
//  OXApiDiningMenusResponse.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/28/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXApiDiningMenuDto.h"

@interface OXApiDiningMenusResponse : JSONModel

@property (strong, nonatomic) NSString<Optional> *error_msg;
@property (strong, nonatomic) NSNumber<Optional> *error_num;
@property (strong, nonatomic) NSArray<OXApiDiningMenuDto> *cardapios;
@property (strong, nonatomic) NSNumber<Optional> *resultado;

@end
