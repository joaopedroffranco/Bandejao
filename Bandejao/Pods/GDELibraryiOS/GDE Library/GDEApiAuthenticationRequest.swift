//
//  GdeApiService.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public class GDEApiConfiguration {
    
    static var defaultConfiguration : GDEApiConfiguration =
        GDEApiConfiguration(
            httpClient: URLSessionHTTPClient(),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15)
    
    let cachePolicy : NSURLRequest.CachePolicy
    let timeoutInterval : TimeInterval
    let httpClient : GDEApiHTTPClient
    
    init(httpClient : GDEApiHTTPClient,
         cachePolicy : NSURLRequest.CachePolicy,
         timeoutInterval : TimeInterval) {
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.httpClient = httpClient
    }
    
    static func setDefaultConfiguration(configuration: GDEApiConfiguration) {
        defaultConfiguration = configuration
    }
}

public class GDEApiAuthenticationRequest : GDEApiRequest {
    
    let publicKeyPath : String
    
    public init(configuration: GDEApiConfiguration, publicKeyPath : String) {
        self.publicKeyPath = publicKeyPath
        super.init(configuration: configuration)
    }
    
    public init(publicKeyPath : String) {
        self.publicKeyPath = publicKeyPath
        super.init()
    }
    
    public override init() {
        guard let keypath = Bundle.main.path(forResource: "public_key", ofType: "der") else {
            fatalError("public_key.der file missing! It should be in the root of the project: \"./public_key.der\". Otherwise, init this class with the public key path.")
        }
        self.publicKeyPath = keypath
        super.init()
    }
    
    public func execute(
        login: String,
        password: String,
        onSuccess:@escaping ((GDEApiAuthenticationResponse) -> Void),
        onError:@escaping ((GDEApiAuthenticationError) -> Void)) {
        
        let iv = AES256Utils.random128IV()
        let symmetricKey : Data = AES256Utils.random256BitAESKey() as Data
        
        guard let rsa = RSA(publicKeyFilePath: publicKeyPath) else {
            onError(GDEApiAuthenticationError.InvalidRSAPublicKey)
            return
        }
        
        let encryptedLoginInfo : String = rsa.encrypt(to: String(format:"{ \"login\": \"%@\", \"senha\": \"%@\", \"iv\": \"%@\", \"chave\": \"%@\" }", login, password, iv.base64EncodedString(), symmetricKey.base64EncodedString()))
        
        // Create request info using encrypted data as info in json
        let requestInfo : String = createLoginInfo(encryptedRequestInfo: encryptedLoginInfo)
        
        // Prepare request
        guard let apiUrl = URL(string: GDEApiContants.GDEApiAuthUrl) else {
            onError(GDEApiAuthenticationError.InvalidApiURL)
            return
        }
        
        var urlRequest : URLRequest = URLRequest(
            url: apiUrl,
            cachePolicy: configuration.cachePolicy,
            timeoutInterval: configuration.timeoutInterval)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = requestInfo.data(using: String.Encoding.utf8)
        
        // Perform 1st phase request
        configuration.httpClient.performRequest(urlRequest: urlRequest, onSuccess: { (responseDataIn64baseRep) -> Void in
            // responseData data comes in UTF8. The string is a base64 rep of the data
            
            let responseDataIn64String = String(data: responseDataIn64baseRep, encoding: String.Encoding.utf8)
            
            // Decrypt with RSA public key
            guard let encryptedData : Data = NSData(fromBase64String: responseDataIn64String) as Data?,
                let decryptedData = rsa.decrypt(with: encryptedData) else {
                fatalError("RSA Decryption failed")
            }
            
//            let decryptedString = String(data: decryptedData, encoding: String.Encoding.utf8)
            
            // Get Response dictionary
            do {
                let responseDict : NSDictionary = try JSONSerialization.jsonObject(with: decryptedData, options: []) as! NSDictionary
                
                if let rand : String = responseDict["rand"] as? String,
                    let code : String = responseDict["code"] as? String {
                    
                    self.performAuthentication(rand: rand, code: code, symmetricKey: symmetricKey, iv: iv as Data, onSuccess: onSuccess, onError: onError)
                } else {
                    onError(GDEApiAuthenticationError.AuthenticationFailed)
                }
            } catch {
                onError(GDEApiAuthenticationError.InvalidServerResponse)
            }
        })
    }
    
    private func createLoginInfo(encryptedRequestInfo : String) -> String {
        return String(format: "{ \"app\" : \"ios\", \"code\" : null, \"dados\" : \"%@\" }", encryptedRequestInfo).replacingOccurrences(of: "\n", with: "")
    }
    
    private func performAuthentication(
        rand: String,
        code : String,
        symmetricKey: Data,
        iv: Data,
        onSuccess:@escaping ((GDEApiAuthenticationResponse) -> Void),
        onError:@escaping ((GDEApiAuthenticationError) -> Void)) {
        
        let secondPhaseInfo = String(format:"{\"rand\": \"%@\"}", rand)
        let secondPhaseEncryptedData : Data = AES256forGDE.encrypt(secondPhaseInfo.data(using: String.Encoding.utf8)!, key: symmetricKey, iv: iv)
        
        let secondPhaseEncryptedString = secondPhaseEncryptedData.base64EncodedString()
        
        let secondPhaseRequest = String(format:"{\"app\": \"ios\", \"code\": \"%@\", \"dados\":\"%@\"}", code, secondPhaseEncryptedString)
        
        guard let apiUrl = URL(string: GDEApiContants.GDEApiAuthUrl) else {
            onError(GDEApiAuthenticationError.InvalidApiURL)
            return
        }
        
        // Prepare request
        var urlRequest : URLRequest = URLRequest(
            url: apiUrl,
            cachePolicy: configuration.cachePolicy,
            timeoutInterval: configuration.timeoutInterval)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = secondPhaseRequest.data(using: String.Encoding.utf8)
        
        configuration.httpClient.performRequest(urlRequest: urlRequest) { data in
            do {
            let responseDict = try self.dictionaryFromAES256ResponseData(data: data, symmetricKey: symmetricKey, iv: iv)
                if let response : Bool = responseDict["resultado"] as? Bool,
                    let sid : String = responseDict["sid"] as? String,
                    response == true {

                        let apiResponse = GDEApiAuthenticationResponse(sid: sid, symmetricKey: symmetricKey)
                        onSuccess(apiResponse)
                    
                    } else {
                        onError(GDEApiAuthenticationError.AuthenticationFailed)
                    }
            } catch {
                onError(GDEApiAuthenticationError.InvalidServerResponse)
            }
        }
    }
}
