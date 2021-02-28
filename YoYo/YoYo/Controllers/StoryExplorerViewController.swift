//
//  StoryExplorerViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/28/21.
//

import UIKit
import SDWebImage
import AVKit

class StoryExplorerViewController: UIViewController {

    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var storyIndexNumber: UILabel!
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var titleAndViewsView: UIView!
    
    var friendStory: FriendStory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDataToView()
    }
    
    private func setupView() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
        titleAndViewsView.layer.cornerRadius = 5.0
        progressStackView.layer.cornerRadius = 2.0
    }
    
    private func loadDataToView() {
        if let friendStory = friendStory {
            profileImageView.sd_setImage(with: URL(string: friendStory.userModel.profilePictureURL), completed: nil)
            profileName.text = friendStory.userModel.name
            let noOfStories = friendStory.stories?.count ?? 0
            for _ in 0..<noOfStories {
                let progressView = UIProgressView()
                progressView.backgroundColor = .lightGray
                progressView.trackTintColor = .lightGray
                progressView.progressTintColor = .black
                progressView.progress = 0.0
                progressView.layer.cornerRadius = 2.0
                progressStackView.addArrangedSubview(progressView)
            }
        }
    }
    
    
}
