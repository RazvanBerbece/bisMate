//
//  public.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 06/08/2021.
//

import Foundation
import SwiftyRSA

public class Public {
    
    private let publicKey = """
        -----BEGIN PUBLIC KEY-----
        MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDoGjuHF8LBZfHqWA1BNL7HNPdV
        nXkqNS+gdtC35QwAs77RWG6olbbBsHy4VlHl2WlYbqA/hy5Hw4/JGamJKjE5pWqs
        ku32e2a4L65BC2ISEwKd3BSCOqo5DDngWItnmnI+19MTkusXogrDVDh65WLjhi9K
        GscccQuvh1J3SVWZ/wIDAQAB
        -----END PUBLIC KEY-----
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
