//
//  CreateAccountController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/7/21.
//

import UIKit
import Firebase

class CreateAccountController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    private var authenticationService = AuthenticationService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        imagePicker.delegate = self
        dobPicker.maximumDate = Calendar.current.date(byAdding: .year, value: -14, to: Date())
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        profileImageView.layer.cornerRadius = 75.0
        profileImageView.clipsToBounds = true
        authenticationService.delegate = self
    }
    
    @IBAction func profileImageTapped(_ sender: UITapGestureRecognizer) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        if(validateFields(name, email, password, confirmPassword)) {
            authenticationService.createUserAccount(email: email, password: password)
        }
    }
    
    // MARK:- Private helper methods
    private func validateFields(_ name: String, _ email: String, _ password: String, _ confirmPassword: String) -> Bool {
        if name.count == 0 || email.count == 0 || password.count == 0 || confirmPassword.count == 0 {
            presentAlert(message: "All fields are mandatory")
            return false
        } else if (password != confirmPassword) {
            presentAlert(message: "Passwords are not matching")
            return false
        } else if (!checkPasswordForComplexity(password)) {
            presentAlert(message: "Password is not strong enough. Password should have atleast one lowercase, one uppercase, one special symbol, minimum six characters and maximum 20 characters")
            return false
        }
        return true
    }
    
    private func checkPasswordForComplexity(_ password: String) -> Bool {
        let passwordValidationRegex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[$@$#!%*?&]).{6,20}$")
        return passwordValidationRegex.evaluate(with: password)
    }
    
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK:- UITextField Delegate Methods
extension CreateAccountController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK:- UIImagePicker Delegate Methods
extension CreateAccountController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- Authentication Delegate Methods
extension CreateAccountController: AuthenticationDelegate {
    func signInToUserAccountFailure(msg: String) {
        /// NOT REQUIRED IN THIS FILE
    }
    
    func signInToUserAccountSuccess(user: User) {
        /// NOT REQUIRED IN THIS FILE
    }
    
    func createUserAccountFailure(msg: String) {
        presentAlert(message: msg)
    }
    
    func createUserAccountSuccess(user: User) {
        print(user)
    }
}
