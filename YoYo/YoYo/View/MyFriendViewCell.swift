//
//  MyFriendViewCell.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/16/21.
//

import UIKit

class MyFriendViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var unfriendButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var unblockButton: UIButton!
    
    var uid: String?
    
    private let friendService = FriendService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
        acceptButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        unfriendButton.layer.cornerRadius = 5
        blockButton.layer.cornerRadius = 5
        unblockButton.layer.cornerRadius = 5
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        friendService.performActionForFriend(friendUID: uid!, action: FRIEND_ACTION.ACCEPT)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        friendService.performActionForFriend(friendUID: uid!, action: FRIEND_ACTION.CANCEL)
    }
    
    @IBAction func unfriendButtontapped(_ sender: Any) {
        friendService.performActionForFriend(friendUID: uid!, action: FRIEND_ACTION.UNFRIEND)
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        friendService.performActionForFriend(friendUID: uid!, action: FRIEND_ACTION.BLOCK)
    }
    
    @IBAction func unblockButtonTapped(_ sender: Any) {
        friendService.performActionForFriend(friendUID: uid!, action: FRIEND_ACTION.UNBLOCK)
    }
    
}
