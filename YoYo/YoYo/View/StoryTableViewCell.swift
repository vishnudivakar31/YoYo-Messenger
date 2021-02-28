//
//  StoryTableViewCell.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/27/21.
//

import UIKit

class StoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    var friendStory:FriendStory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        friendImageView.layer.borderWidth = 1.0
        friendImageView.layer.masksToBounds = false
        friendImageView.layer.borderColor = CGColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1)
        friendImageView.layer.cornerRadius = friendImageView.layer.bounds.height / 2
        friendImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
