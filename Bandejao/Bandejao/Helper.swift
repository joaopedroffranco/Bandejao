//
//  Helper.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import Foundation

struct Identifiers {
    static let mealController = "mealController"
}

extension Date {
    
    var string: String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .long
        return dateformatter.string(from: self)
    }
    
}
