//
//  Meal.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit

class Meal: NSObject {

    var main: String!
    var salad: String?
    var dessert: String?
    var juice: String?
    var vegan: String?
    
    init(main: String, salad: String = "", dessert: String = "", juice: String = "", vegan: String = "") {
        self.main = main
        self.salad = salad
        self.dessert = dessert
        self.juice = juice
        self.vegan = vegan
    }
    
}
