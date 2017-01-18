//
//  GDEApiAuthenticatorResponse.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

public enum GDEApiAuthenticationError : Error {
    case InvalidRSAPublicKey
    case InvalidApiURL
    case InvalidServerResponse
    case AuthenticationFailed
}

public class GDEApiAuthenticationResponse {
    
    public let sid : String
    public let symmetricKey : Data
    
    init(sid: String, symmetricKey: Data) {
        self.sid = sid
        self.symmetricKey = symmetricKey
    }
}
