//
//  MessagesViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 30/01/2021.
//

import UIKit

/** Simple structure of a message in the message list */
class Message {
    public var from     : String?
    public var headline : String?
    public var time     : String?
    
    /** Constructor */
    init(from: String, headline: String, time: String) {
        self.from = from
        self.headline = headline
        self.time = time
    }
}

class MessagesViewController: UITableViewController {
    
    var model = [Message]()
    
    override func viewDidLoad() {
        
        // Init
        self.messageInit()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Setting cell layout
        cell.textLabel?.text = "\(String(describing: model[indexPath.row].from!))"
        cell.detailTextLabel?.text = "\(String(describing: model[indexPath.row].headline!))"
        cell.imageView?.image = UIImage(systemName: "questionmark")
        
        // Make cells transparent
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.backgroundColor = .clear
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MessageDetailSegue", sender: indexPath)
    }
    
    // MARK: Utils
    private func messageInit() {
        // tableView init
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        tableView.isEditing = false;
        // model init
        self.model.append(Message(from: "2", headline: "Msg prototype", time: "24:00"))
    }
    
    // MARK: Segue preparing for detailed message views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageDetailSegue" {
            print("Segueing")
            let MessageDetailView = segue.destination as! MessageDetailViewController
            if let indexPath = sender as? IndexPath {
                MessageDetailView.MessageWithUserID = model[indexPath.row].from
            }
        }
    }
    
}