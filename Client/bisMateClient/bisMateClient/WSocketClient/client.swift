//
//  client.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import Foundation
import SwiftyJSON

/** Represents JSON encodable data that can be sent to the server */
struct EncodableMessage: Codable {
    let text: String?
    let fromID: Int?
    let toID: Int?
}

/** Handles websocket connection to server, sending & receiving messages */
public class WSClient {
    
    private let urlSession      : URLSession?
    private let webSocketTask   : URLSessionWebSocketTask?
    private let clientID        : Int?
    
    /** Constructor */
    init(id: Int) {
        
        self.clientID = id
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
    public func openConn(callback: @escaping (Bool) -> Void) { // opens connection to the websocket server
        self.webSocketTask!.resume()
        callback(true)
    }
    
    /** Send message over websocket to user with ID from current user ID */
    public func sendMessage(fromID: Int, toID: Int, inputMessage: String) { // sends message to ws server
        do {
            // Encode message using the EncodableMessage struct
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
    
    /** Receive message over websocket on current ID */
    public func getMessage(callback: @escaping (String) -> Void) { // reads messages received from server
        self.webSocketTask!.receive {
            (result) in
            switch result {
            case .failure(let error):
                print("Receive err : \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    // Convert the stringified json response to a Swift dictionary obj
                    if let data = text.data(using: String.Encoding.utf8) {
                        do {
                            if let messageObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                // Use this dictionary
                                print(messageObject)
                                print("Received on \(String(describing: self.clientID!)) : " + "\(messageObject["text"]!)")
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
                self.getMessage() {
                    (messageAux) in
                    // NOTHING HERE
                }
            }
        }
    }
    
}

public class HTTPClient {
    
    private var token : String? // user token ?
    
    /** Constructor */
    init(token: String) {
        self.token = token
    }
    
    /** Setters */
    public func setToken(newTok: String) {
        self.token = newTok
    }
    
    /** Tests if the HTTP server is up and running */
    public func testHTTPConn(callback: @escaping (Int) -> Void) {
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 8000
        components.path = "/conn"
        
        let url = components.url
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data
            else {
                callback(0)
                return
            }
            callback(1)
        }
        task.resume()
        
    }
    
    /** Initiates an operation on the server using the current user's token */
    public func sendOperationWithToken(operation: String, input: String, callback: @escaping (Int) -> Void) {
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 8000
        components.path = "/operation"
        components.queryItems = [
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "operation", value: operation),
            URLQueryItem(name: "input", value: input)
        ]
        
        let url = components.url
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else {
                callback(0)
                return
            }
            
            // server response parsing
            let jsonString = String(data: data, encoding: .utf8)
            let jsonData = jsonString!.data(using: .utf8)
            if let json = try? JSON(data: jsonData!) {
                if (json["Result"] != 0) {
                    callback(1)
                }
                else {
                    callback(0)
                }
            }
            else {
                callback(0)
            }
        }
        task.resume()
        
    }
    
}
