//
//  SettingsViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/18/21.
//

import UIKit
import SDWebImage

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var emailTextLabel: UILabel!
    
    private let settingsService = SettingsService()
    private let imagePicker = UIImagePickerController()
    private var userModel: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
        profileImageView.clipsToBounds = true
        settingsService.delegate = self
        imagePicker.delegate = self
        settingsService.fetchUserProfile()
    }
    
    @IBAction func changeNameTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Change name", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "enter your new name"
        }
        let changeAction = UIAlertAction(title: "Change", style: .default) { (_) in
            let textField = alertController.textFields?.first
            let newName = textField!.text!
            if newName.count > 0 {
                self.settingsService.changeName(name: newName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func requestPasswordTapped(_ sender: Any) {
        settingsService.sendPasswordResetRequest(email: emailTextLabel.text!)
    }
    
    @IBAction func deleteAccountTapped(_ sender: Any) {
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        if !settingsService.logout() {
            presentAlert(title: "Logout", msg: "unable to logout right now. please try again later")
        }
    }
    
    @IBAction func changeProfilePictureTapped(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func presentAlert(title: String, msg: String) {
        let uiAlertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        uiAlertController.addAction(okAction)
        present(uiAlertController, animated: true, completion: nil)
    }
    
}

// MARK:- Service Delegate Methods
extension SettingsViewController: SettingsDelegate {
    func uploadImageStatus(status: Bool, msg: String) {
        presentAlert(title: "Upload Profile picute", msg: msg)
        if status {
            self.settingsService.fetchUserProfile()
        }
    }
    
    func changeNameStatus(status: Bool, error: Error?) {
        if status {
            self.settingsService.fetchUserProfile()
        } else if let error = error {
            presentAlert(title: "Change Name Error", msg: error.localizedDescription)
        } else {
            presentAlert(title: "Change Name Error", msg: "Unable to change your name.")
        }
    }
    
    func sendPasswordResetStatus(error: Error?) {
        if let error = error {
            presentAlert(title: "Reset password", msg: error.localizedDescription)
        } else {
            presentAlert(title: "Reset password", msg: "Please follow the instructions specified in the email.")
        }
    }
    
    func fetchUserProfileSuccess(userModel: UserModel) {
        self.userModel = userModel
        profileImageView.sd_setImage(with: URL(string: userModel.profilePictureURL), completed: nil)
        nameTextLabel.text = userModel.name
        emailTextLabel.text = userModel.userEmail
    }
}

// MARK:- UIImagePicker Delegate Methods
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let userModel = userModel {
            if let data = pickedImage.jpegData(compressionQuality: 1) {
                self.settingsService.changeProfilePhoto(imageData: data, imageURL: userModel.profilePictureURL)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
