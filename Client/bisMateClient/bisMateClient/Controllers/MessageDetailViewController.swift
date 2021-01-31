//
//  MessageDetailViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 31/01/2021.
//

import UIKit

class MessageDetailViewController: UIViewController {
    
    // UI Components
    @IBOutlet weak var fieldMessageInput: UITextField!
    
    // Message Logic from previous view
    var MessageWithUserID : String?
    
    // Sockets
    var socketClient : SocketClient?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // print(MessageWithUserID)
        // Do any additional setup after loading the view.
    }
    
    @IBAction private func sendMessageAction() {
        // TODO
        let input = self.fieldMessageInput.text
        print(input)
    }
    
}
