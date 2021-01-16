//
//  ViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 15/01/2021.
//

import UIKit

class ViewController: UIViewController {
    
    let wsclientOne = WSClient(id: 1)
    let wsclientTwo = WSClient(id: 2)

    override func viewDidLoad() {
        
        wsclientOne.openConn()
        wsclientTwo.openConn()
        super.viewDidLoad()
        
        wsclientOne.sendMessage(fromID: 1, toID: 2, inputMessage: "Hello from 1 !!")
        wsclientTwo.sendMessage(fromID: 2, toID: 1, inputMessage: "Hello from 2 !!")
        wsclientOne.getMessage()
        
    }


}

