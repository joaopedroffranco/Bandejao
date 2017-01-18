//
//  GDEApiHTTPClient.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public protocol GDEApiHTTPClient {
    
    func performRequest(urlRequest: URLRequest, onSuccess:@escaping ((Data) -> Void))
}
