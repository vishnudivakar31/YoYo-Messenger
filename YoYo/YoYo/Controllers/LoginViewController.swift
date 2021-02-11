//
//  LoginViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/10/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var baseView: UIView!
    
    private let authenticationService: AuthenticationService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStackView.layer.cornerRadius = 25.0
        loginStackView.clipsToBounds = true
        activityIndicator.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        authenticationService.userLoginDelegate = self
        authenticationService.passwordResetDelegate = self
        addKeyboardObserverMethods()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        if email.count == 0 || password.count == 0 {
            presentAlert(title: "Login Attempted", message: "Please fill in both email and password to login")
        } else  {
            activityIndicator.isHidden = false
            authenticationService.signInToUserAccount(email: email, password: password)
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Password Reset Request", message: "Enter your email address", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "email address"
            textField.keyboardType = .emailAddress
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let textField = alertController.textFields?.first else {return}
            let email = textField.text ?? ""
            if email.count > 0 {
                self.authenticationService.forgotPassword(email: email)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
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
        loginStackView.layoutMargins.bottom = 8
    }
    
    // MARK:- Private functions
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- UITextField Delegate Methods
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK:- UserLogin Delegate Methods
extension LoginViewController: UserLoginDelegate {
    func signInToUserAccountFailure(msg: String) {
        presentAlert(title: "Login Failed", message: msg)
        activityIndicator.isHidden = true
    }
    
    func signInToUserAccountSuccess(user: User, isVerified: Bool) {
        if(!isVerified) {
            self.authenticationService.reSendVerificationEmail()
        } else {
            presentAlert(title: "Login Successful", message: "You did it.")
            /// TODO: Implement further login
        }
        activityIndicator.isHidden = true
    }
    
    func resendEmailVerificationSuccess() {
        presentAlert(title: "Login Successful", message: "You have not verified your email. A new email verification is generated. Please verify the email and login to proceed.")
        activityIndicator.isHidden = true
    }
    
    func resendEmailVerificationFailed(msg: String) {
        presentAlert(title: "Login Successful", message: "You have not verified your email but resending verification email failed. Reason: (\(msg). Please try later")
        activityIndicator.isHidden = true
    }
}

// MARK:- Password Reset Delegate Methods
extension LoginViewController: PasswordResetDelegate {
    func passwordResetSuccess() {
        presentAlert(title: "Password Reset Initiated", message: "You will be getting a password reset email. Please follow the email")
    }
    
    func passwordResetFailed(msg: String) {
        presentAlert(title: "Password Reset Failed", message: "\(msg)")
    }
}
