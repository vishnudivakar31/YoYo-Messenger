//
//  LoginViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/10/21.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStackView.layer.cornerRadius = 25.0
        loginStackView.clipsToBounds = true
    }
}
