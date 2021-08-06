//
//  SummaryMessageCell.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 31/07/2021.
//

import Foundation
import UIKit

/**
 Custom cell class which is used for a message container (of remote user)
 */
class SummaryMessageCell: UITableViewCell {
    
    @IBOutlet weak var userPhotoView    : UIImageView!
    @IBOutlet weak var userNameLabel    : UILabel!
    @IBOutlet weak var messageLabel     : UILabel!
    // @IBOutlet weak var timeLabel     : UILabel!
    
}
