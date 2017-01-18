//
//  GDEApiDiningMenuResponse.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public class GDEApiDiningResponse {
    
    public let error : String?
    public let error_num : Int?
    public let menuList : [GDEApiDiningMenu]
    public let result : Int?
    
    init(dictionary : NSDictionary) {
        
        if let error = dictionary["error"] as? String {
            self.error = error
        } else {
            self.error = nil
        }
        
        if let error_num = dictionary["error_num"] as? String {
            self.error_num = Int(error_num)
        } else {
            self.error_num = nil
        }
        
        if let menuRawList = dictionary["cardapios"] as? NSArray {
            var menuList : [GDEApiDiningMenu] = []
            for value in menuRawList {
                if let value = value as? NSDictionary {
                    menuList.append(GDEApiDiningMenu(dictionary: value))
                }
            }
            self.menuList = menuList
        } else {
            self.menuList = []
        }
        
        if let result = dictionary["resultado"] as? String {
            self.result = Int(result)
        } else {
            self.result = nil
        }
    }
}
