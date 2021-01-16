//
//  client.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import Foundation

/** Represents JSON encodable data that can be sent to the server */
struct EncodableMessage: Codable {
    let text: String?
    let fromID: Int?
    let toID: Int?
}

/** Handles websocket connection to server, sending & receiving messages */
class WSClient {
    
    private let wsAddress       : String?
    private let urlSession      : URLSession?
    private let webSocketTask   : URLSessionWebSocketTask?
    private let clientID        : Int?
    
    /** Constructor */
    init(id: Int) {
        
        self.clientID = id
        self.wsAddress = "ws://localhost:8000/ws"
        self.urlSession = URLSession(configuration: .default)
        
        var components = URLComponents()
        components.scheme = "ws"
        components.host = "localhost"
        components.port = 8000
        components.path = "/ws"
        components.queryItems = [
            URLQueryItem(name: "clientID", value: "\(String(describing: self.clientID!))")
        ]
        self.webSocketTask = self.urlSession!.webSocketTask(with: components.url!)
    }
    
    /** WebSocket Methods -- will need completion handlers at some point */
    public func openConn() { // opens connection to the websocket server
        self.webSocketTask!.resume()
    }
    
    public func sendMessage(fromID: Int, toID: Int, inputMessage: String) { // sends message to ws server
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(EncodableMessage(text: inputMessage, fromID: fromID, toID: toID))
            let message = URLSessionWebSocketTask.Message.data(data)
            
            self.webSocketTask!.send(message) {
                (error) in
                if let err = error {
                    // err handling
                    print(err)
                }
            }
        }
        catch {
            // err handling
            print(error)
        }
    }
    
    public func getMessage() { // reads messages received from server
        self.webSocketTask!.receive {
            (result) in
            switch result {
            case .failure(let error):
                print("Receive err : \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: String.Encoding.utf8) {
                        do {
                            if let messageObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                // Use this dictionary
                                print("Received on \(self.clientID) : " + "\(messageObject["text"]!)")
                            }
                        } catch {
                            print(error)
                        }
                    }
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
                // call again to receive (real-time behaviour)
                self.getMessage()
            }
        }
    }

}
