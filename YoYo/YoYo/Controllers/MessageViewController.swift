//
//  MessageViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addKeyboardObserverMethods()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        
        let uiToolBar = UIToolbar()
        uiToolBar.sizeToFit()
        
        let uiDoneBarItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(dismissKeyBoard))
        uiToolBar.items = [uiDoneBarItem]
        
        messageTextView.inputAccessoryView = uiToolBar
        messageTextView.backgroundColor = .white
        messageTextView.textColor = .black
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 0.8)
        messageTextView.layer.cornerRadius = 5.0
    }

    private func addKeyboardObserverMethods() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func dismissKeyBoard() {
        self.messageTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               return
            }
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

}
