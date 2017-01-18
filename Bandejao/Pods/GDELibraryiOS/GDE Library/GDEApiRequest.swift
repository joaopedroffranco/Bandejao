//
//  GDEApiRequest.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public class GDEApiRequest {
    
    var configuration : GDEApiConfiguration
    
    init(configuration : GDEApiConfiguration) {
        self.configuration = configuration
    }
    
    init() {
        self.configuration = GDEApiConfiguration.defaultConfiguration
    }
    
    func dictionaryFromAES256ResponseData(data: Data, symmetricKey: Data, iv: Data) throws -> NSDictionary {
        let responseString = String(data: data, encoding: String.Encoding.utf8)
        let encodedData : Data = NSData.init(fromBase64String: responseString) as Data
        let decodedData = AES256forGDE.decrypt(encodedData, key: symmetricKey, iv: iv)
        do {
            return try JSONSerialization.jsonObject(with: decodedData!, options: []) as! NSDictionary
        } catch {
            throw GDEApiAuthenticationError.InvalidServerResponse
        }
    }
}
