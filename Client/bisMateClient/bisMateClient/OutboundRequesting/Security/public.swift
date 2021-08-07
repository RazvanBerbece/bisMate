//
//  public.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 06/08/2021.
//

import Foundation
import SwiftyRSA

public class Public {
    
    fileprivate let publicKey = """
        MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIrg0dbvTtOuLmkl6BPdYnrUwvMrOsS5
        TyMi8J696WzqaqxojSqf2V6wRS/ZC18FeD8Mqs4HBuDJpINJ7Adb8gMCAwEAAQ==
        """
    
    public func getBase64PublicKey() -> PublicKey? {
        do {
            let publicKey = try PublicKey(base64Encoded: self.publicKey)
            return publicKey
        }
        catch {
            print("Error creating public key object")
            return nil
        }
    }
    
}
