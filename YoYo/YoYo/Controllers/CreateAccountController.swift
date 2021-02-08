//
//  CreateAccountController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/7/21.
//

import UIKit

class CreateAccountController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    
    
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
        
    }
    
    @IBAction func profileImageTapped(_ sender: UITapGestureRecognizer) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
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
