//
//  SendRequestController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit

class SendRequestController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let requestService = RequestServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.clipsToBounds = true
        
        messageTextField.layer.borderWidth = 0.5
        messageTextField.layer.borderColor = UIColor.gray.cgColor
        messageTextField.clipsToBounds = true
        
        activityIndicator.isHidden = true
    }
    @IBAction func sendButtonTapped(_ sender: Any) {
        let email: String = emailTextField.text ?? ""
        let message: String = messageTextField.text ?? ""
        activityIndicator.isHidden = false
        self.requestService.sendAddFriendRequest(email: email, msg: message) { (success) in
            if success {
                self.presentAlert(title: "Friend Request", msg: "Send successfully")
                self.activityIndicator.isHidden = true
            } else {
                self.presentAlert(title: "Friend Request", msg: "Send unsuccessfully. Please try again later")
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- UITextField delegate methods
extension SendRequestController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
