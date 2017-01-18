//
//  OXDiningMenuDto.h
//  GDE App
//
//  Created by Nicholas Matuzita Mizoguchi on 8/24/15.
//  Copyright (c) 2015 GDE. All rights reserved.
//

#import "JSONModel.h"
@class OXApiDiningMenuDto;

@protocol OXApiDiningMenuDto <NSObject>
@end

@interface OXApiDiningMenuDto : JSONModel

@property (strong, nonatomic) NSString<Optional> *data;
@property (strong, nonatomic) NSString<Optional> *ultima_atualizacao;
@property (strong, nonatomic) NSString<Optional> *guarnicao;
@property (strong, nonatomic) NSNumber<Optional> *id_anterior;
@property (strong, nonatomic) NSNumber<Optional> *id_cardapio;
@property (strong, nonatomic) NSNumber<Optional> *id_proximo;
@property (strong, nonatomic) NSString<Optional> *principal;
@property (strong, nonatomic) NSString<Optional> *pts;
@property (strong, nonatomic) NSString<Optional> *salada;
@property (strong, nonatomic) NSString<Optional> *sobremesa;
@property (strong, nonatomic) NSString<Optional> *suco;
@property (strong, nonatomic) NSNumber<Optional> *tipo;
@property (strong, nonatomic) NSString<Optional> *vegetariano;
@property (strong, nonatomic) NSNumber<Optional> *proximo;

@end
