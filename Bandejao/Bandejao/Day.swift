//
//  Day.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit

class Day: NSObject {

    var date: Date!
    var breakfast: Meal!
    var lunch: Meal!
    var dinner: Meal!

    init(date: Date, breakfast: Meal, lunch: Meal, dinner: Meal) {
        self.date = date
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }
    
}
