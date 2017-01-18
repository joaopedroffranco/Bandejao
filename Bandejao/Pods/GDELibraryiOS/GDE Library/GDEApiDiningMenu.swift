//
//  GDEApiDiningMenu.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public class GDEApiDiningMenu {
    public let data : String?
    public let ultima_atualizacao : String?
    public let guarnicao : String?
    public let id_anterior: Int?
    public let id_cardapio: Int?
    public let id_proximo: Int?
    public let principal: String?
    public let pts : String?
    public let salada: String?
    public let sobremesa: String?
    public let suco: String?
    public let tipo: Int?
    public let vegetariano: String?
    public let proximo: Int?
    
    init(dictionary : NSDictionary) {
        
        if let data = dictionary["data"] as? String {
            self.data = data
        } else {
            self.data = nil
        }
        
        if let ultima_atualizacao = dictionary["ultima_atualizacao"] as? String {
            self.ultima_atualizacao = ultima_atualizacao
        } else {
            self.ultima_atualizacao = nil
        }
        
        if let guarnicao = dictionary["guarnicao"] as? String {
            self.guarnicao = guarnicao
        } else {
            self.guarnicao = nil
        }
        
        if let id_anterior = dictionary["id_anterior"] as? String {
            self.id_anterior = Int(id_anterior)
        } else {
            self.id_anterior = nil
        }
        
        if let id_cardapio = dictionary["id_cardapio"] as? String {
            self.id_cardapio = Int(id_cardapio)
        } else {
            self.id_cardapio = nil
        }
        
        if let id_proximo = dictionary["id_proximo"] as? String {
            self.id_proximo = Int(id_proximo)
        } else {
            self.id_proximo = nil
        }
        
        if let principal = dictionary["principal"] as? String {
            self.principal = principal
        } else {
            self.principal = nil
        }
        
        if let pts = dictionary["pts"] as? String {
            self.pts = pts
        } else {
            self.pts = nil
        }
        
        if let salada = dictionary["salada"] as? String {
            self.salada = salada
        } else {
            self.salada = nil
        }
        
        if let sobremesa = dictionary["sobremesa"] as? String {
            self.sobremesa = sobremesa
        } else {
            self.sobremesa = nil
        }
        
        if let suco = dictionary["suco"] as? String {
            self.suco = suco
        } else {
            self.suco = nil
        }
        
        if let tipo = dictionary["tipo"] as? String {
            self.tipo = Int(tipo)
        } else {
            self.tipo = nil
        }
        
        if let vegetariano = dictionary["vegetariano"] as? String {
            self.vegetariano = vegetariano
        } else {
            self.vegetariano = nil
        }
        
        if let proximo = dictionary["proximo"] as? String {
            self.proximo = Int(proximo)
        } else {
            self.proximo = nil
        }
    }
}
