//
//  client.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import Foundation
import Alamofire

/** Represents JSON encodable data that can be sent to the server */
struct EncodableMessage: Codable {
    let text: String?
    let fromID: String?
    let toID: String?
}

/** Handles websocket connection to server, sending & receiving messages */
public class SocketClient {
    
    public var request          : Alamofire.Request?
    private let clientID        : String?
    
    /** Constructor */
    init(id: String) {
        
        self.clientID = id
        
        var components = URLComponents()
        components.scheme = "ws"
        components.host = "macbook.local"
        components.port = 8000
        components.path = "/ws"
        components.queryItems = [
            URLQueryItem(name: "clientID", value: self.clientID)
        ]
        let url = components.url
        // self.request = URLRequest(url: components.url!)
        self.request = AF.request(URLRequest(url: url!))
        // request!.timeoutInterval = 5
        
    }
    
}
