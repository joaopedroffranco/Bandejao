//
//  ViewController.swift
//  Bandejao
//
//  Created by Joao Pedro Fabiano Franco on 16/01/17.
//  Copyright © 2017 Joao Pedro Fabiano Franco. All rights reserved.
//

import UIKit
import GDELibraryiOS

class DiningPageViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mealContainerView: UIView!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageViewController: UIPageViewController?
    var diningResponse: GDEApiDiningResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.isHidden = true
        
        loadingIndicatorView.startAnimating()
        GDEApiAuthenticationRequest().execute(login: Constants.loginRA, password: Constants.loginPassword, onSuccess: { (response) in
                GDEApiDiningRequest().execute(sid: response.sid, symmetricKey: response.symmetricKey, onSuccess: { (diningResponse) in
                        self.diningResponse = diningResponse
                        DispatchQueue.main.async {
                            if let first = self.diningResponse.menuList.first{
                                self.dateLabel.text = first.data
                            }
                            self.initPageController()
                            self.loadingIndicatorView.isHidden = true
                        }
                }, onError: { (diningError) in
                    self.loadingIndicatorView.isHidden = true
                    print(diningError)
                })
        }, onError: { (error) in
            print(error)
        })
    }
 
    
// MARK: - Private
    
    private func initPageController(){
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
        pageViewController!.setViewControllers([viewControllerAtIndex(index: 0)! as! MenuViewController], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageViewController!)
        self.mealContainerView.addSubview(self.pageViewController!.view)
        
        let pageViewRect = self.mealContainerView.bounds
        pageViewController!.view.frame = pageViewRect
        pageViewController!.didMove(toParentViewController: self)
        
        pageControl.numberOfPages = self.diningResponse.menuList.count/2
    }

}

// MARK: - PageController Delegate

extension DiningPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((diningResponse.menuList.count == 0) || (index >= diningResponse.menuList.count/2)) {
            return nil
        }
        
        let menuController = self.storyboard?.instantiateViewController(withIdentifier: Identifiers.menuController) as! MenuViewController
        menuController.lunch = self.diningResponse.menuList[2*index]
        menuController.dinner = self.diningResponse.menuList[2*index+1]
        menuController.pageIndex = index
        self.navigationItem.title = self.diningResponse.menuList[index].data
        
        return menuController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MenuViewController).pageIndex!
        
        index += 1
        if(index >= self.diningResponse.menuList.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MenuViewController).pageIndex!
        
        if(index <= 0){
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.diningResponse.menuList.count/2
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

