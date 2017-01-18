//
//  NSURLSessionHTTPClient.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

class URLSessionHTTPClient : GDEApiHTTPClient {
    
    func performRequest(urlRequest: URLRequest, onSuccess:@escaping ((Data) -> Void)) {
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession.init(configuration: configuration)
        
        let task = urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data, error == nil {
                onSuccess(data)
            }
        })
        
        task.resume()
    }
}
