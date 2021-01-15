//
//  client.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import Foundation

/** Message component */
public enum Message {
    case data(Data)
    case string(String)
}

/** Handles websocket connection to server, sending & receiving messages */
class WSClient {
    
    private let wsAddress       : String?
    private let urlSession      : URLSession?
    private let webSocketTask   : URLSessionWebSocketTask?
    
    /** Constructor */
    init() {
        self.wsAddress = "ws://localhost:8000/ws"
        self.urlSession = URLSession(configuration: .default)
        self.webSocketTask = self.urlSession!.webSocketTask(with: URL(string: self.wsAddress!)!)
    }
    
    /** Methods */
    public func openConn() { // opens connection to the websocket server
        self.webSocketTask!.resume()
    }
    
    public func sendMessage(message: String, callback: @escaping (String) -> Void) { // sends message to ws server
        let message = URLSessionWebSocketTask.Message.string(message)
        self.webSocketTask!.send(message) {
            (err) in
            if let error = err {
                print("sendMessage(): \(error)")
            }
        }
    }
    
}
