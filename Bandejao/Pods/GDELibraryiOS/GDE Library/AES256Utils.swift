//
//  AES256Utils.swift
//  GDE Library
//
//  Created by Nicholas Matuzita Mizoguchi on 17/01/17.
//  Copyright © 2017 GDE. All rights reserved.
//

import Foundation

class AES256Utils {
    
    static func random128IV() -> NSData {
        return randomKey(numberOfBytes: 16)
    }
    
    static func random256BitAESKey() -> NSData {
        return randomKey(numberOfBytes: 32)
    }
    
    private static func randomKey(numberOfBytes: Int) -> NSData {
        if let data = NSMutableData(length: numberOfBytes) {
            let unsafePointer : UnsafeMutablePointer<UInt8>
            unsafePointer = unsafeBitCast(data.mutableBytes, to: UnsafeMutablePointer<UInt8>.self)
            let result = SecRandomCopyBytes(kSecRandomDefault, numberOfBytes, unsafePointer)
            if result >= 0 {
                return data
            } else {
                fatalError("Problem generating random AES")
            }
        }
        fatalError("Problem creating NSData for random AES")
    }
}
