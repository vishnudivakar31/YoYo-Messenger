//
//  SendMediaMessageViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/10/21.
//

import UIKit
import AVKit

class SendMediaMessageViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private let messagingService = MessagingService()
    
    var uploadAsset: UploadAsset?
    var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addKeyboardObserverMethods()
        
        if let assetData = uploadAsset {
            if assetData.mediaType == .IMAGE {
                messageImageView.isHidden = false
                messageImageView.image = UIImage(data: assetData.data)
            } else {
                messageImageView.isHidden = true
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
        inputStackView.layer.cornerRadius = 5.0
        titleTextField.layer.borderWidth = 1.5
        titleTextField.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        titleTextField.layer.cornerRadius = 5.0
        titleTextField.textColor = .black
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        titleTextField.clipsToBounds = true
        titleTextField.delegate = self
        
        sendButton.layer.cornerRadius = 5.0
        sendButton.clipsToBounds = true
        
        activityIndicator.isHidden = true
    }
    
    @IBAction func onSendButtonTapped(_ sender: Any) {
        if let uploadAsset = uploadAsset, let userModel = userModel {
            let title = titleTextField.text ?? ""
            if title.count > 0 {
                messagingService.uploadMedia(data: uploadAsset.data, mediaType: uploadAsset.mediaType, fileName: title, userID: userModel.userID) { (url, error) in
                    if error != nil {
                        self.presentAlert(success: false, msg: error?.localizedDescription ?? "")
                    } else if let url = url {
                        let myUID = self.messagingService.getMyUID()
                        let messageType: MESSAGE_TYPE = uploadAsset.mediaType == MEDIA_TYPE.IMAGE ? .IMAGE : .VIDEO
                        let message = Message(senderID: myUID, receiverID: userModel.userID, date: Date(), messageType: messageType, messageStatus: .SEND, message: title, assetURL: url)
                        self.messagingService.sendMessageUsing(message: message) { (success, msg) in
                            if success {
                                self.presentAlert(success: true, msg: "Successful")
                            } else {
                                self.presentAlert(success: false, msg: "Failed. Try again later.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func presentAlert(success: Bool, msg: String) {
        let alertController = UIAlertController(title: "Message media upload", message: msg, preferredStyle: .alert)
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
        if self.bottomConstraint.constant == 8 {
            self.animateBottomView(constant: self.bottomConstraint.constant + keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.bottomConstraint.constant != 0 {
            self.animateBottomView(constant: 8)
        }
    }
    
    private func animateBottomView(constant: CGFloat) {
        UIView.animate(withDuration: 1) {
            self.bottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK:- UITextFieldDelegate
extension SendMediaMessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
