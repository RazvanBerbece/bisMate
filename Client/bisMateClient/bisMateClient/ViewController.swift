//
//  ViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import UIKit

class ViewController: UIViewController {
    
    let wsclient = WSClient()

    override func viewDidLoad() {
        
        wsclient.openConn()
        super.viewDidLoad()
        
        wsclient.sendMessage(message: "Hello server !") {
            (response) in
            print("Message sent !")
        }
        
    }


}

