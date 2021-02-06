//
//  RestClient.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 22/01/2021.
//

import Foundation
import SwiftyJSON

public class RestClient {
    
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
        components.host = "192.168.120.38"
        components.port = 8000
        components.path = "/conn"
        
        let url = components.url
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            guard let data = data else {
                callback(0)
                return
            }
            callback(1)
        }
        task.resume()
        
    }
    
    /** Initiates an operation on the server using the current user's token */
    public func sendOperationWithToken(operation: String, input: String, callback: @escaping (JSON, Int) -> Void) { // closure Int represents presence of error if != 0
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "192.168.120.38"
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
                callback("", 1)
                return
            }
            // server response parsing
            let json = self.parseResponseData(data: data)
            if (json != "") {
                if (json["Result"] == 1) {
                    callback(json, 0)
                }
                else {
                    callback(json, 1)
                }
            }
            else {
                callback("", 1)
            }
        }
        task.resume()
        
    }
    
    /** Utils */
    
    /** Gets a data input and returns a parsed JSON structure */
    private func parseResponseData(data: Data) -> JSON {
        let jsonString = String(data: data, encoding: .utf8)
        let jsonData = jsonString!.data(using: .utf8)
        if let json = try? JSON(data: jsonData!) { // successfully parsed
            return json
        }
        return ""
    }
    
}
