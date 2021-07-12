//
//  MessagesViewController.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 30/01/2021.
//

import UIKit

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

/** Simple structure of a message in the message list */
class Message {
    public var from     : String?
    public var text     : String?
    public var time     : Int64?
    private var uid     : String?
    
    /** Constructor */
    init(from: String, text: String, time: Int64, uid: String) {
        self.from = from
        self.text = text
        self.time = time
        self.uid = uid
    }
    
    /** Getters */
    public func getUID() -> String {
        return self.uid!
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
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Setting cell layout
        cell.textLabel?.text = "\(String(describing: model[indexPath.row].from!))"
        cell.detailTextLabel?.text = "\(String(describing: model[indexPath.row].text!))"
        cell.imageView?.image = UIImage(systemName: "questionmark")
        
        // Make cells transparent
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.backgroundColor = .clear
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MessageDetailSegue", sender: indexPath)
    }
    
    // MARK: - Utils
    private func messageInit() {
        
        // tableView init
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        tableView.isEditing = false;
        
        // model init -- in a for loop (uses default uid2 for now)
        let defaultUID = (Singleton.sharedInstance.CurrentLocalUser!.getUID() == "ezQDaTAMkfM9IL1lQ1dvEKULrHv2" ? "jaq3RAOFuBar41BySERkP0WPugZ2" : "ezQDaTAMkfM9IL1lQ1dvEKULrHv2")
        self.model.append(Message(from: "Jon Doe", text: "Hello World !", time: Date().currentTimeMillis(), uid: defaultUID))
        
    }
    
    // MARK: - Segue preparing for detailed message views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageDetailSegue" {
            print("Segueing")
            let MessageDetailView = segue.destination as! MessageDetailViewController
            if let indexPath = sender as? IndexPath {
                MessageDetailView.MessageWithUserID = model[indexPath.row]
                MessageDetailView.TitleName = model[indexPath.row].from
            }
        }
    }
    
}
