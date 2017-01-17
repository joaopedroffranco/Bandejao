//
//  ViewController.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit

class DaysViewController: UIViewController {

    @IBOutlet weak var mealContainerView: UIView!
    
    var pageViewController: UIPageViewController?
    var days: [Day] = []
    var currentDay: Day!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mockDays()
        initPageController()
    }
    
    func mockDays() {
        let now = Date()
        for i in 0...6 {
            let breakfast = Meal(main: "Cafe da manha \(i)")
            let lunch = Meal(main: "Almoco Prato \(i)", salad: "Almoco Salada \(i)", dessert: "Almoco Sobremesa \(i)", juice: "Almoco Suco \(i)", vegan: "Almoco Vegetariano \(i)")
            let dinner = Meal(main: "Dinner Prato \(i)", salad: "Dinner Salada \(i)", dessert: "Dinner Sobremesa \(i)", juice: "Dinner Suco \(i)", vegan: "Dinner Vegetariano \(i)")
            days.append(Day(date: now.addingTimeInterval(Double(i)*3600*24), breakfast: breakfast, lunch: lunch, dinner: dinner))
        }
    }
 
    
// MARK: - Private
    
    private func initPageController(){
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
        
        let startingViewController = viewControllerAtIndex(index: 0)! as! MealTableViewController
        let daysPage = [startingViewController]
        
        currentDay = days[0]
        
        pageViewController!.setViewControllers(daysPage, direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageViewController!)
        self.mealContainerView.addSubview(self.pageViewController!.view)
        
        let pageViewRect = self.mealContainerView.bounds
        pageViewController!.view.frame = pageViewRect
        pageViewController!.didMove(toParentViewController: self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }

}

// MARK: - PageController Delegate

extension DaysViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((days.count == 0) || (index >= days.count)) {
            return nil
        }
        
        let mealController = self.storyboard?.instantiateViewController(withIdentifier: Identifiers.mealController) as! MealTableViewController
        mealController.day = days[index]
        mealController.pageIndex = index
        self.navigationItem.title = days[index].date.string
        
        return mealController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MealTableViewController).pageIndex!
        
        currentDay = days[index]
        
        index += 1
        if(index >= days.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MealTableViewController).pageIndex!
        
        currentDay = days[index]
        
        if(index <= 0){
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {  if (finished){
            currentDay = days[(previousViewControllers.first as! MealTableViewController).pageIndex!]
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return days.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

