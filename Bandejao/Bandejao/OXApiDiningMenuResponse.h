//
//  OXDiningMenuResponse.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/24/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import "JSONModel.h"
#import "OXApiDiningMenuDto.h"
@interface OXApiDiningMenuResponse : JSONModel

@property (strong, nonatomic) NSString<Optional> *error_msg;
@property (strong, nonatomic) NSNumber<Optional> *error_num;
@property (strong, nonatomic) OXApiDiningMenuDto *cardapio;
@property (strong, nonatomic) NSNumber<Optional> *resultado;

@end
