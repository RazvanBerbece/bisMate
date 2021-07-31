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

struct SeguedData {
    var indexPath    : IndexPath?
    var profilePic   : UIImage?
}

class MessagesViewController: UITableViewController {
    
    var model = [Message]()
    
    var remoteProfilePic: UIImage?
    
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
        
        let customCell : SummaryMessageCell = self.tableView.dequeueReusableCell(withIdentifier: "SummaryMessageCell") as! SummaryMessageCell
        
        // Setting cell layout
        customCell.userNameLabel?.text = "\(String(describing: model[indexPath.row].from!))"
        customCell.messageLabel?.text = "\(String(describing: model[indexPath.row].text!))"
        
        self.getRemoteProfilePic(forUID: model[indexPath.row].getUID()) {
            (image) in
            DispatchQueue.main.async {
                customCell.userPhotoView?.maskCircleWithShadow(anyImage: image)
                self.styleImageView(forCell: customCell)
                self.tableView.reloadData()
            }
        }
        
        // Make cells transparent
        customCell.layer.backgroundColor = UIColor.clear.cgColor
        customCell.backgroundColor = .clear
        
        return customCell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.getRemoteProfilePic(forUID: model[indexPath.row].getUID()) {
            (image) in
            let seguedData = SeguedData(indexPath: indexPath, profilePic: image)
            self.performSegue(withIdentifier: "MessageDetailSegue", sender: seguedData)
        }
        
    }
    
    // MARK: - Utils
    private func messageInit() {
        
        // tableView init
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        tableView.isEditing = false;
        
        // populate table view from connections array
        for connection in Singleton.sharedInstance.matches! {
            // get user data from uid
            Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "0", input: connection) {
                (result, status) in
                if (result != "") {
                    let user = User.getUserFromData(data: result)
                    self.model.append(Message(from: user.getDisplayName(), text: "Start up a conversation !", time: Date().currentTimeMillis(), uid: connection))
                    self.tableView.reloadData()
                }
                else {
                    print("Error occured while collecting nearby users.")
                }
            }
        }
    }
    
    private func getRemoteProfilePic(forUID: String, callback: @escaping (UIImage) -> (Void)) {
        // get user profile pic
        Singleton.sharedInstance.HTTPClient?.sendOperationWithToken(operation: "ppg", input: forUID) {
            (result, errStatus) in
            if (result != "") {
                if (result["Data"] != "") { // decode base64 and display image
                    DispatchQueue.main.async {
                        let fixedBase64 = result["Data"].stringValue.fixedBase64Format
                        let dataDecoded = Data.init(base64Encoded: fixedBase64, options: .ignoreUnknownCharacters)
                        let decodedImage = UIImage(data: dataDecoded!)
                        callback(decodedImage!)
                    }
                }
                else { // display default user pic
                    callback(UIImage(systemName: "person.fill")!)
                }
            }
            else {
                print("Error occured while downloading profile picture.")
                callback(UIImage(systemName: "person.fill")!)
            }
        }
    }
    
    private func styleImageView(forCell: SummaryMessageCell) {
        // user profile pic image view graphics
        let itemSize = CGSize.init(width: 45, height: 45)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        forCell.userPhotoView?.image!.draw(in: imageRect)
        forCell.userPhotoView?.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        forCell.userPhotoView?.layer.cornerRadius = forCell.userPhotoView!.frame.height / 2
        UIGraphicsEndImageContext();
    }
    
    // MARK: - Segue preparing for detailed message views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueData = sender as? SeguedData
        else { return }
        if segue.identifier == "MessageDetailSegue" {
            print("Segueing")
            let MessageDetailView = segue.destination as! MessageDetailViewController
            if let indexPath = segueData.indexPath {
                MessageDetailView.MessageWithUserID = model[indexPath.row]
                MessageDetailView.TitleName = model[indexPath.row].from
                MessageDetailView.RemoteProfilePic = segueData.profilePic
            }
        }
    }
    
}
