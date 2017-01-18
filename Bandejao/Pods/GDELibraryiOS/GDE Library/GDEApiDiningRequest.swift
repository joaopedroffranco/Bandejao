//
//  GDEApiDiningRequest.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public enum GDEApiRequestError : Error {
    case InvalidResponse
}

public class GDEApiDiningRequest : GDEApiRequest {
    
    public override init() {
        super.init()
    }
    
    public func execute(
        sid: String,
        symmetricKey: Data,
        onSuccess:@escaping((GDEApiDiningResponse) -> Void),
        onError:@escaping((GDEApiRequestError) -> Void)) -> Void {
        let iv : Data = AES256Utils.random128IV() as Data
        let requestInfo : String = String(format:"{\"sid\": \"%@\", \"iv\":\"%@\", \"dados\": {} }", sid, iv.base64EncodedString())
        
        guard let url = URL(string: GDEApiContants.GDEApiDiningMenuUrl) else {
            return
        }
        var urlRequest : URLRequest = URLRequest(
            url: url,
            cachePolicy: configuration.cachePolicy,
            timeoutInterval: configuration.timeoutInterval)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = requestInfo.data(using: String.Encoding.utf8)
        
        configuration.httpClient.performRequest(urlRequest: urlRequest) { (data) in
            do {
                let responseDict = try self.dictionaryFromAES256ResponseData(
                    data: data,
                    symmetricKey:
                    symmetricKey,
                    iv: iv)
                onSuccess(GDEApiDiningResponse(dictionary: responseDict))
            } catch {
                onError(GDEApiRequestError.InvalidResponse)
            }
        }
    }
}
