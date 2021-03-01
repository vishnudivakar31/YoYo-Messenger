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
    
    private var index = 0
    private var totalStories = 0
    private var timer: Timer?
    private let player = AVPlayer()
    private var playerLayer: AVPlayerLayer?
    private let storyService = StoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadDataToView()
        playStoryAt(index: index)
    }
    
    private func setupView() {
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
        titleAndViewsView.layer.cornerRadius = 5.0
        progressStackView.layer.cornerRadius = 2.0
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.view.bounds
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(playerLayer!, at: 0)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(quitThisView))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        player.pause()
        if let timer = timer {
            timer.invalidate()
        }
        let touchPoint = sender.location(in: self.view)
        let originalIndex = self.index
        if touchPoint.x <= self.view.center.x {
            self.index -= 1
        } else {
            self.index += 1
        }
        let progressView = progressStackView.subviews[originalIndex] as! UIProgressView
        if originalIndex > self.index {
            progressView.progress = 0
        } else {
            progressView.progress = 1
        }
        
        self.playStoryAt(index: self.index)
    }
    
    @objc private func quitThisView() {
        if let nav = self.navigationController {
            invalidateAllResources()
            nav.popViewController(animated: true)
        } else {
            invalidateAllResources()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func invalidateAllResources() {
        player.pause()
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    private func loadDataToView() {
        if let friendStory = friendStory {
            profileImageView.sd_setImage(with: URL(string: friendStory.userModel.profilePictureURL), completed: nil)
            profileName.text = friendStory.userModel.name
            totalStories = friendStory.stories?.count ?? 0
            for _ in 0..<totalStories {
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
    
    private func playStoryAt(index: Int) {
        if index == totalStories || index < 0 {
            quitThisView()
            return
        }
        
        if let friendStory = friendStory, let stories = friendStory.stories {
            let story = stories[index]
            storyTitle.text = story.title
            viewsCountLabel.text = "\(story.viewedBy.count) views"
            self.storyService.addViews(story: story) { (error) in
                if let error = error {
                    self.presentAlert(title: "Updating views", msg: error.localizedDescription)
                }
            }
            if story.mediaType == .IMAGE {
                showStoryImage(story: story, index: index)
            } else {
                showStoryVideo(story: story, index: index)
            }
        }
    }
    
    private func showStoryImage(story: Story, index: Int) {
        let delay = 5.0
        let progressView = progressStackView.subviews[index] as! UIProgressView
        storyIndexNumber.text = "\(delay) seconds"
        
        storyImageView.isHidden = false
        
        if let playerLayer = playerLayer {
            playerLayer.isHidden = true
        }
        
        storyImageView.sd_setImage(with: URL(string: story.assetURL)) { (_, error, _, _) in
            if error == nil {
                self.generateProgess(progressView: progressView, delay: delay)
            }
        }
    }
    
    private func showStoryVideo(story: Story, index: Int) {
        let asset = AVURLAsset(url: URL(string: story.assetURL)!)
        let delay = asset.duration.seconds
        let progressView = progressStackView.subviews[index] as! UIProgressView
        storyIndexNumber.text = "\(round(delay)) seconds"
        
        storyImageView.isHidden = true
        if let playerLayer = playerLayer {
            playerLayer.isHidden = false
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        player.play()
        
        generateProgess(progressView: progressView, delay: delay)
    }
    
    private func generateProgess(progressView: UIProgressView, delay: Double) {
        var count = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
            count += 0.001
            progressView.progress = Float(count / delay)
            if count >= delay {
                timer.invalidate()
                self.index += 1
                self.playStoryAt(index: self.index)
            }
        }
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
