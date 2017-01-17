//
//  MealTableViewController.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController {
    @IBOutlet weak var breakfastLabel: UILabel!
    
    @IBOutlet weak var lunchMainLabel: UILabel!
    @IBOutlet weak var lunchSaladLabel: UILabel!
    @IBOutlet weak var lunchDessertLabel: UILabel!
    @IBOutlet weak var lunchJuiceLabel: UILabel!
    @IBOutlet weak var lunchVeganLabel: UILabel!
    
    @IBOutlet weak var dinnerMainLabel: UILabel!
    @IBOutlet weak var dinnerSaladLabel: UILabel!
    @IBOutlet weak var dinnerDessertLabel: UILabel!
    @IBOutlet weak var dinnerJuiceLabel: UILabel!
    @IBOutlet weak var dinnerVeganLabel: UILabel!
    
    var day: Day!
    var pageIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakfastLabel.text = self.day.breakfast.main
        
        lunchMainLabel.text = self.day.lunch.main
        lunchSaladLabel.text = self.day.lunch.salad!
        lunchDessertLabel.text = self.day.lunch.dessert!
        lunchJuiceLabel.text = self.day.lunch.juice!
        lunchVeganLabel.text = self.day.lunch.vegan!
        
        dinnerMainLabel.text = self.day.dinner.main
        dinnerSaladLabel.text = self.day.dinner.salad!
        dinnerDessertLabel.text = self.day.dinner.dessert!
        dinnerJuiceLabel.text = self.day.dinner.juice!
        dinnerVeganLabel.text = self.day.dinner.vegan!
    }


}
