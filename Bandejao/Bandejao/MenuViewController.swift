//
//  MealTableViewController.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit
import GDELibraryiOS

class MenuViewController: UIViewController {
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var saladLabel: UILabel!
    @IBOutlet weak var dessertLabel: UILabel!
    @IBOutlet weak var juiceLabel: UILabel!
    @IBOutlet weak var veganLabel: UILabel!
    
    var lunch: GDEApiDiningMenu!
    var dinner: GDEApiDiningMenu!
    var pageIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayLabel.text = lunch.data!.date.string
        
        mainLabel.text = self.lunch.principal
        saladLabel.text = self.lunch.salada
        dessertLabel.text = self.lunch.sobremesa
        juiceLabel.text = self.lunch.suco
        veganLabel.text = self.lunch.vegetariano
    }
    
    // MARK: - Segment Control
    
    @IBAction func switchMenu(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            dayLabel.text = lunch.data!.date.string
            
            mainLabel.text = self.lunch.principal?.text
            saladLabel.text = self.lunch.salada?.text
            dessertLabel.text = self.lunch.sobremesa?.text
            juiceLabel.text = self.lunch.suco?.text
            veganLabel.text = self.lunch.vegetariano?.text
        case 1:
            dayLabel.text = dinner.data!.date.string
            
            mainLabel.text = self.dinner.principal?.text
            saladLabel.text = self.dinner.salada?.text
            dessertLabel.text = self.dinner.sobremesa?.text
            juiceLabel.text = self.dinner.suco?.text
            veganLabel.text = self.dinner.vegetariano?.text
        default:
            break; 
        }
    }
    


}
