//
//  security.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 06/08/2021.
//

import Foundation
import SwiftyRSA

class Security {
    
    public func encryptUserInput(input: String) -> String? {
        do {
            let clearMsg = try ClearMessage(string: input, using: .utf8)
            do {
                let PublicStruct = Public()
                if let publicKey = PublicStruct.getBase64PublicKey() {
                    let encrypted = try clearMsg.encrypted(with: publicKey, padding: .PKCS1)
                    return encrypted.base64String
                }
                else {
                    print("Error while getting public key.")
                    return nil
                }
            }
        }
        catch {
            print("Error creating clear message.")
            return nil
        }
    }
    
    public func decryptedUserInputString(input: EncryptedMessage) -> String? {
        let PrivateStruct = Private()
        if let privateKey = PrivateStruct.getBase64PrivateKey() {
            do {
                let clearMessage = try input.decrypted(with: privateKey, padding: .PKCS1)
                do {
                    let string = try clearMessage.string(encoding: .utf8)
                    return string
                }
                catch {
                    print("Error occured while getting string representation of decrypted message.")
                    return nil
                }
            }
            catch {
                print("Error occured decrypting message.")
                return nil
            }
        }
        else {
            print("Error occured while getting private key.")
            return nil
        }
    }
    
}
