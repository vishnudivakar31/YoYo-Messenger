//
//  StoriesViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/25/21.
//

import UIKit
import AVKit
import SDWebImage
import Firebase

struct UploadAsset {
    var data:Data
    var videoURL: URL?
    var mediaType:MEDIA_TYPE
}

class StoriesViewController: UIViewController {

    @IBOutlet weak var myStoryStackView: UIStackView!
    @IBOutlet weak var myStoryImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMyStoryButton: UIButton!
    
    private var tableStories: [FriendStory] = []
    private var myStories: [Story] = []
    private let imagePicker = UIImagePickerController()
    private let storyService = StoryService()
    
    private var listnerForStory: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        imagePicker.delegate = self
        storyService.delegate = self
        storyService.fetchMyStories()
        storyService.fetchMyFriendsStories()
        toggleMyStory(status: myStories.count > 0)
        storyService.registerForStories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let listnerForStory = listnerForStory {
            listnerForStory.remove()
        }
    }
    
    private func setupView() {
        myStoryImageView.layer.borderWidth = 2.5
        myStoryImageView.layer.masksToBounds = false
        myStoryImageView.layer.borderColor = myStories.count == 0 ? CGColor(red: 0, green: 0, blue: 0, alpha: 0.2) : CGColor(red: 108, green: 92, blue: 231, alpha: 1)
        myStoryImageView.layer.cornerRadius = myStoryImageView.layer.bounds.height / 2
        myStoryImageView.clipsToBounds = true
        
        showMyStoryButton.setTitleColor(UIColor(cgColor: CGColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1)), for: .normal)
        showMyStoryButton.setTitleColor(.darkGray, for: .disabled)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x:0, y: self.myStoryStackView.frame.size.height - 1, width: self.myStoryStackView.frame.size.width, height:1)
        bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        myStoryStackView.layer.addSublayer(bottomBorder)
        storyService.fetchUserModel(uid: nil) { (userModel) in
            if let userModel = userModel {
                self.myStoryImageView.sd_setImage(with: URL(string: userModel.profilePictureURL), completed: nil)
            }
        }
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "StoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func toggleMyStory(status: Bool) {
        showMyStoryButton.isEnabled = status
        myStoryImageView.layer.borderColor = status ? CGColor(red: 39/255, green: 60/255, blue: 117/255, alpha: 1) : CGColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        myStoryImageView.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UploadImageStoryViewController {
            let viewController = segue.destination as! UploadImageStoryViewController
            if let uploadAsset = sender as? UploadAsset {
                viewController.assetData = uploadAsset
            }
        }
    }
    
    @IBAction func showMyStoriesTapped(_ sender: Any) {
    }
    
    @IBAction func addStoriesTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    
}

// MARK:- Image Picker Delegate Methods
extension StoriesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var videoLengthConstraintMet = true
        var errorMsg = ""
        var assetData: Data?
        let mediaType = info[.mediaType]
        var uploadAsset: UploadAsset?
        if mediaType != nil && mediaType as! String == "public.image" {
            if let pickedImage = info[.originalImage] as? UIImage {
                assetData = pickedImage.jpegData(compressionQuality: 1)
                uploadAsset = UploadAsset(data: assetData!, mediaType: .IMAGE)
            } else {
                videoLengthConstraintMet = false
                errorMsg = "Unable to load image. Try again later"
            }
        } else if mediaType != nil && mediaType as! String == "public.movie" {
            let videoURL = info[.mediaURL] as? URL
            if let videoURL = videoURL {
                let asset = AVURLAsset(url: videoURL)
                let duration = asset.duration.seconds
                if duration > 60 {
                    videoLengthConstraintMet = false
                    errorMsg = "Story should be less than 60 seconds."
                } else {
                    do {
                        assetData =  try Data(contentsOf: videoURL, options: .mappedIfSafe)
                        uploadAsset = UploadAsset(data: assetData!, videoURL: videoURL, mediaType: .VIDEO)
                    } catch {
                        videoLengthConstraintMet = false
                        errorMsg = error.localizedDescription
                    }
                }
            }
        }
        imagePicker.dismiss(animated: true) {
            if let uploadAsset = uploadAsset {
                self.performSegue(withIdentifier: "GoToStoryUploadImage", sender: uploadAsset)
            }
        }
        if !videoLengthConstraintMet {
            presentAlert(title: "Story uploading failed", msg: errorMsg)
        }
    }
}

// MARK:- StoryDelegate Methods
extension StoriesViewController: StoryDelegate {
    func registerForStories(listener: ListenerRegistration) {
        self.listnerForStory = listener
    }
    
    func changeDetected(status: Bool) {
        if status {
            self.storyService.fetchMyStories()
            self.storyService.fetchMyFriendsStories()
        }
    }
    
    func fetchFriendsStory(stories: [FriendStory]?, error: Error?) {
        if let error = error {
            self.presentAlert(title: "Stories", msg: error.localizedDescription)
        } else if let stories = stories {
            self.tableStories = stories
            self.tableView.reloadData()
        }
    }
    
    func fetchMyStory(stories: [Story]?, error: Error?) {
        if let stories = stories {
            self.toggleMyStory(status: stories.count > 0)
            self.myStories = stories
        } else if let error = error {
            self.presentAlert(title: "My Stories", msg: error.localizedDescription)
        }
    }
}

// MARK:- TableView Delegates
extension StoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendStory = self.tableStories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryTableViewCell", for: indexPath) as! StoryTableViewCell
        cell.friendStory = friendStory
        cell.friendName.text = friendStory.userModel.name
        cell.friendImageView.sd_setImage(with: URL(string: friendStory.userModel.profilePictureURL), completed: nil)
        return cell
    }
}
