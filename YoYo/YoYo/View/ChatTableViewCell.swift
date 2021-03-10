//
//  ChatTableViewCell.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/9/21.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var numberOfUnreadMessages: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
