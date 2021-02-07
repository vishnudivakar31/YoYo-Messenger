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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        dobPicker.maximumDate = Calendar.current.date(byAdding: .year, value: -14, to: Date())
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
    }
    
}

extension CreateAccountController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
