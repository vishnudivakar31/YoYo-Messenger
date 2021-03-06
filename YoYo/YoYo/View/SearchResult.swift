//
//  SearchResult.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import UIKit

class SearchResult: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    private let friendService = FriendService()
    private let authenticationService = AuthenticationService()
    
    var uid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.borderWidth = 1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        profileImage.layer.cornerRadius = profileImage.layer.bounds.height / 2
        profileImage.clipsToBounds = true
        sendButton.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        friendService.sendFriendRequest(myUID: authenticationService.getUserID()!, friendUID: uid!) { (success) in
            if success {
                sender.isEnabled = false
                sender.backgroundColor = .darkGray
            }
        }
    }
    
}
