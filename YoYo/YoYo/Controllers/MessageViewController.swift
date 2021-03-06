//
//  MessageViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import UIKit
import AVKit
import Firebase

class MessageViewController: UIViewController {

    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let imagePicker = UIImagePickerController()
    private var messages: [Message] = []
    private var listeners: [ListenerRegistration] = []
    private let messagingService = MessagingService()
    
    var userModel:UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        loadDataToView()
        addKeyboardObserverMethods()
        messagingService.delegate = self
        imagePicker.delegate = self
        if let userModel = userModel {
            messagingService.fetchMessages(receiverID: userModel.userID)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let userModel = userModel {
            let listeners = messagingService.registerForMessages(uid: userModel.userID)
            self.listeners.append(contentsOf: listeners)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        for listener in listeners {
            listener.remove()
        }
    }
    
    private func loadDataToView() {
        if let userModel = userModel {
            profileImageView.sd_setImage(with: URL(string: userModel.profilePictureURL), completed: nil)
            friendName.text = userModel.name.components(separatedBy: " ")[0]
        }
    }
    
    private func setupView() {
        
        let uiToolBar = UIToolbar()
        uiToolBar.sizeToFit()
        
        let uiFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let uiDoneBarItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(dismissKeyBoard))
        uiToolBar.items = [uiFlexibleSpace, uiDoneBarItem]
        
        messageTextView.inputAccessoryView = uiToolBar
        messageTextView.backgroundColor = .white
        messageTextView.textColor = .black
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        messageTextView.layer.cornerRadius = 10.0
        
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        bottomStackView.layer.borderWidth = 0.5
        bottomStackView.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 1, blue: 1, alpha: 1.0))
        // tableView.rowHeight = 80
    }

    @IBAction func callButtonTapped(_ sender: Any) {
    }
    
    @IBAction func videoCallTapped(_ sender: Any) {
    }
    
    @IBAction func closeChatTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addMediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        let messageTxt = messageTextView.text ?? ""
        if let userModel = userModel {
            if messageTxt.count > 0 {
                messagingService.sendMessage(msg: messageTxt, receiverID: userModel.userID, messageType: .PLAIN, assetURL: nil) { (success, msg) in
                    self.messageTextView.text = ""
                    if !success {
                        self.presentAlert(title: "Message Status", msg: msg ?? "")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SendMediaMessageViewController {
            let viewController = segue.destination as! SendMediaMessageViewController
            if let uploadAsset = sender as? UploadAsset, let userModel = userModel {
                viewController.uploadAsset = uploadAsset
                viewController.userModel = userModel
            }
        } else if segue.destination is PreviewMediaViewController {
            let viewController = segue.destination as! PreviewMediaViewController
            if let message = sender as? Message {
                viewController.message = message
            }
        } else if segue.destination is PreviewVideoViewController {
            let viewController = segue.destination as! PreviewVideoViewController
            if let message = sender as? Message {
                viewController.message = message
            }
        }
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func addKeyboardObserverMethods() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateMessagesToSeen() {
        let _ = messagingService.changeMessageStatusToSeen(messages: self.messages)
        self.tableView.reloadData()
    }
    
    private func animateBottomView(constant: CGFloat) {
        UIView.animate(withDuration: 1) {
            self.bottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyBoard() {
        self.messageTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               return
        }
        if self.bottomConstraint.constant == 0 {
            self.animateBottomView(constant: self.bottomConstraint.constant + keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.bottomConstraint.constant != 0 {
            self.animateBottomView(constant: 0)
        }
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async() {
            if self.messages.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }

}

// MARK:- Table Delegate Methods
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        cell.message = message
        cell.myUID = messagingService.getMyUID()
        cell.drawCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        if message.messageType == .IMAGE {
            performSegue(withIdentifier: "PreviewImage", sender: message)
        } else if message.messageType == .VIDEO {
            performSegue(withIdentifier: "PreviewVideo", sender: message)
        }
    }
    
}

// MARK:- Messaging Service Delegate Methods
extension MessageViewController: MessageServiceDelegate {
    
    func modifiedMessageDetected(modifiedMessages: [Message], msg: String) {
        let modifiedMessageIDs = modifiedMessages.compactMap { return $0.id }
        for i in 0 ..< self.messages.count {
            if(modifiedMessageIDs.contains(self.messages[i].id!)) {
                self.messages[i].messageStatus = .SEEN
            }
        }
        self.tableView.reloadData()
    }
    
    func fetchMessagesCompleted(messages: [Message], error: Error?) {
        if error != nil {
            presentAlert(title: "Fetching Messages", msg: error?.localizedDescription ?? "")
        } else {
            self.messages = messages
            self.updateMessagesToSeen()
            self.scrollToBottom()
        }
    }
    
    func getMyFriendsCompleted(friends: [UserModel]?, error: Error?) {
        // NOT REQUIRED IN THIS CONTROLLER
    }
    
    func newMessageDetected(newMessages: [Message], msg: String) {
        if newMessages.count > 0 {
            self.messages.append(contentsOf: newMessages)
            self.updateMessagesToSeen()
            self.scrollToBottom()
        }
    }

}

// MARK:- Image Picker Delegate Methods
extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                self.performSegue(withIdentifier: "SendMediaMessage", sender: uploadAsset)
            }
        }
        if !videoLengthConstraintMet {
            presentAlert(title: "Story uploading failed", msg: errorMsg)
        }
    }
}
