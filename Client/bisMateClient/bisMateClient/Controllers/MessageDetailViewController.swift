//
//  MessageDetailViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 31/01/2021.
//

import UIKit
import Starscream

class DetailViewMessage {
    
    public var message      : String?
    private let time         : Int64?
    private let id          : String?
    
    init(msg: String, time: Int64, id: String) {
        self.message = msg
        self.time = time
        self.id = id
    }
    
    public func getID() -> String {
        return self.id!
    }
    
    public func getTime() -> Int64 {
        return self.time!
    }
}

class MessageDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    
    // UI Components
    @IBOutlet weak var tableViewMessages: UITableView!
    @IBOutlet weak var fieldMessageInput: UITextField!
    @IBOutlet weak var navbarItem: UINavigationItem!
    
    // Cell ids
    let cellReuseIdentifierLeft = "MessageCellLeft"
    let cellReuseIdentifierRight = "MessageCellRight"
    
    // Message Logic from previous view
    var MessageWithUserID : Message?
    var TitleName         : String?
    
    // Client REST API
    let HTTPClient = Singleton.sharedInstance.HTTPClient
    
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
        self.hideKeyboardWhenTappedAround()
        self.initView()
        
        // Keyboard moves below view on field writing to avoid keyboard displaying on top of the textfield
        // https://stackoverflow.com/questions/26070242/move-view-with-keyboard-using-swift
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        super.viewDidLoad()
        
    }
    
    // MARK: - Socket operations
    private func initSockets() {
        socket = WebSocket(request: self.socketClient.request!.request!)
        socket?.delegate = self
        socket?.connect()
    }
    @IBAction private func sendMessageAction() {
        // TODO
        let input = self.fieldMessageInput.text
        if (input != "") {
            // print(input!)
            do {
                // Get current time
                let currentTime = Date().currentTimeMillis()
                // Encode message using the EncodableMessage struct
                let encoder = JSONEncoder()
                let data = try encoder.encode(EncodableMessage(text: input, fromID: self.uid, toID: self.MessageWithUserID!.getUID(), time: currentTime))
                
                self.socket?.write(data: data)
                
                self.model.append(DetailViewMessage(msg: input!, time: currentTime, id: self.uid))
                DispatchQueue.main.async {
                    self.tableViewMessages.reloadData()
                }
                self.fieldMessageInput.text = ""
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
    
    // MARK: - UI Logic
    private func initView() {
        self.navbarItem.title = self.TitleName
    }
    
    // MARK: - Table Logic
    private func tableInit() {
        self.tableViewMessages.delegate = self
        self.tableViewMessages.dataSource = self
        self.tableViewMessages.allowsSelection = true
        self.tableViewMessages.isEditing = false;
        self.tableViewMessages.separatorStyle = .none
        
        // Get messages between users
        self.HTTPClient!.sendOperationWithToken(operation: "z", input: self.MessageWithUserID!.getUID()) {
            (result, status) in
            if (status == 1) {
                let messages = result["Data"]
                for (_, messageDict) in messages.enumerated() {
                    let time = messageDict.1["time"].int64
                    self.model.append(DetailViewMessage(msg: messageDict.1["text"].stringValue, time: time!, id: messageDict.1["fromID"].stringValue))
                    DispatchQueue.main.async {
                        self.tableViewMessages.reloadData()
                    }
                }
            }
            else {
                print("Error occured while downloading messages for this conversation.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Set cell layout according to UID of msg
        if (self.model[indexPath.row].getID() != self.uid) { // peer texts
            
            // Get appropiate cell type
            let cellLeft: MessageCellLeft = self.tableViewMessages.dequeueReusableCell(withIdentifier: self.cellReuseIdentifierLeft) as! MessageCellLeft
            
            // Populate cell with data
            cellLeft.messageLabel?.text = self.model[indexPath.row].message
            cellLeft.userPhotoView?.image = UIImage(systemName: "questionmark")
            
            // Cell attributes
            cellLeft.layer.backgroundColor = UIColor.clear.cgColor
            cellLeft.backgroundColor = .clear
            
            return cellLeft
        }
        else { // own texts
            
            // Get appropiate cell type
            let cellRight: MessageCellRight = self.tableViewMessages.dequeueReusableCell(withIdentifier: self.cellReuseIdentifierRight) as! MessageCellRight
            
            // Populate cell with data
            cellRight.messageLabel?.text = self.model[indexPath.row].message
            cellRight.userPhotoView?.image = UIImage(systemName: "questionmark")
            
            // Cell attributes
            cellRight.layer.backgroundColor = UIColor.clear.cgColor
            cellRight.backgroundColor = .clear
            
            return cellRight
        }
        
    }
    
    // MARK: - WebSockets receiving
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
                        self.model.append(DetailViewMessage(msg: messageObject["text"] as! String, time: messageObject["time"] as! Int64, id: messageObject["fromID"] as! String))
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
    
    // MARK: - Utils
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
