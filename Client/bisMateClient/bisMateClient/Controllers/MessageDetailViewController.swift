//
//  MessageDetailViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 31/01/2021.
//

import UIKit
import Starscream

class DetailViewMessage {
    
    public var message : String?
    private let id     : String?
    
    init(msg: String, id: String) {
        self.message = msg
        self.id = id
    }
    
    public func getID() -> String {
        return self.id!
    }
}

class MessageDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    
    // UI Components
    @IBOutlet weak var tableViewMessages: UITableView!
    @IBOutlet weak var fieldMessageInput: UITextField!
    
    // Message Logic from previous view
    var MessageWithUserID : Message?
    
    // Model for table view
    var model = [DetailViewMessage]() // init with list of messages from Firebase Storage
    
    // Sockets
    var socketClient = SocketClient(id: Singleton.sharedInstance.CurrentLocalUser!.getUID())
    var socket : WebSocket?
    let uid = Singleton.sharedInstance.CurrentLocalUser!.getUID()
    
    override func viewDidLoad() {
        
        // Init
        self.initSockets()
        self.tableInit()
        
        super.viewDidLoad()
        
    }
    
    /** Socket operations */
    private func initSockets() {
        socket = WebSocket(request: self.socketClient.request!)
        socket?.delegate = self
        socket?.connect()
    }
    @IBAction private func sendMessageAction() {
        // TODO
        let input = self.fieldMessageInput.text
        if (input != "") {
            // print(input!)
            do {
                // Encode message using the EncodableMessage struct
                let encoder = JSONEncoder()
                let data = try encoder.encode(EncodableMessage(text: input, fromID: self.uid, toID: self.MessageWithUserID!.getUID()))
                
                self.socket?.write(data: data)
                
                self.model.append(DetailViewMessage(msg: input!, id: self.uid))
                DispatchQueue.main.async {
                    self.tableViewMessages.reloadData()
                }
            }
            catch {
                // err handling
                print(error)
            }
        }
        else {
            // ERR HANDLING
        }
    }
    
    /** Table Logic */
    private func tableInit() {
        self.tableViewMessages.delegate = self
        self.tableViewMessages.dataSource = self
        self.tableViewMessages.register(UITableViewCell.self, forCellReuseIdentifier: "CellMsg")
        self.tableViewMessages.allowsSelection = true
        self.tableViewMessages.isEditing = false;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableViewMessages.dequeueReusableCell(withIdentifier: "CellMsg", for: indexPath)
        
        // Setting cell layout
        cell.textLabel?.text = self.model[indexPath.row].message
        if (self.model[indexPath.row].getID() != self.uid) { // peer texts
            cell.textLabel?.textAlignment = .left; // optional
            cell.imageView?.image = UIImage(systemName: "questionmark")
        }
        else { // own texts
            cell.textLabel?.textAlignment = .right; // optional
            cell.accessoryView = UIImageView(image: UIImage(systemName: "questionmark"))
        }
        
        // Make cells transparent
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.backgroundColor = .clear
        
        return cell
    }
    
    // MARK: WebSockets receiving
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            // self.isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            // self.isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            // Convert the stringified json response to a Swift dictionary obj
            if let data = string.data(using: String.Encoding.utf8) {
                do {
                    if let messageObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        // Use this dictionary
                        print(messageObject)
                        self.model.append(DetailViewMessage(msg: messageObject["text"] as! String, id: messageObject["fromID"] as! String))
                        DispatchQueue.main.async {
                            self.tableViewMessages.reloadData()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled: break
        // isConnected = false
        case .error(let error):
            // isConnected = false
            print(error)
        }
    }
    
}
