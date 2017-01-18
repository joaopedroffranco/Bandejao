//
//  Helper.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import Foundation

struct Identifiers {
    static let menuController = "menuController"
}

struct Constants {
    static let loginRA = "bandecosiri"
    static let loginPassword = "6HCtUdufmDKt4CKe"
}

extension String {
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)!
    }
    
    var text: String {
        return (self != "") ? self : "Não disponível"
    }
}

extension Date {
    
    var string: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd MMMM, yyyy (EEEE)"
        return dateformatter.string(from: self)
    }
    
}
