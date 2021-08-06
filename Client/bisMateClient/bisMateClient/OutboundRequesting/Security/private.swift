//
//  private.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 06/08/2021.
//

import Foundation
import SwiftyRSA

class Private {
    
    static public func getBase64PrivateKey(user: User) -> PrivateKey? {
        do {
            let privateKey = try PrivateKey(base64Encoded: user.getUID().fixedBase64Format)
            return privateKey
        }
        catch {
            print("Error creating public key object")
            return nil
        }
    }
    
}
