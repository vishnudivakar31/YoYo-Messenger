//
//  UploadImageStoryViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/26/21.
//

import UIKit
import AVKit

class UploadImageStoryViewController: UIViewController {

    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var assetData: UploadAsset?
    
    private let storyService = StoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputStackView.layer.cornerRadius = 5.0
        setupView()
        addKeyboardObserverMethods()
        
        if let assetData = assetData {
            if assetData.mediaType == .IMAGE {
                storyImageView.isHidden = false
                storyImageView.image = UIImage(data: assetData.data)
            } else {
                storyImageView.isHidden = true
                let player = AVPlayer(url: assetData.videoURL!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.view.bounds
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                view.layer.insertSublayer(playerLayer, at: 0)
                player.play()
            }
        }
    }
    
    private func setupView() {
        titleTextField.layer.borderWidth = 1.5
        titleTextField.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        titleTextField.layer.cornerRadius = 5.0
        titleTextField.textColor = .black
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        titleTextField.clipsToBounds = true
        titleTextField.delegate = self
        
        uploadButton.layer.cornerRadius = 5.0
        uploadButton.clipsToBounds = true
        
        activityIndicator.isHidden = true
    }
    
    @IBAction func uploadTapped(_ sender: Any) {
        let title = titleTextField.text
        if let uploadAsset = assetData, let title = title {
            if title.count > 0 {
                activityIndicator.isHidden = false
                storyService.uploadStory(uploadAsset: uploadAsset, title: title) { (success, msg) in
                    self.activityIndicator.isHidden = true
                    self.presentAlert(success: success, msg: msg)
                }
            }
        }
    }
    
    private func presentAlert(success: Bool, msg: String) {
        let alertController = UIAlertController(title: "Story upload", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            if success {
                self.resignFirstResponder()
                self.dismiss(animated: true) {
                    if let nav = self.navigationController {
                        nav.popViewController(animated: true)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addKeyboardObserverMethods() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               return
            }
        baseView.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        baseView.frame.origin.y = 0
        inputStackView.layoutMargins.bottom = 8
    }
    
}

// MARK:- UITextFieldDelegate
extension UploadImageStoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
