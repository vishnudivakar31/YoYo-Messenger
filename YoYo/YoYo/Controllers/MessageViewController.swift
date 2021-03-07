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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
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
        
        let uiFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let uiDoneBarItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(dismissKeyBoard))
        uiToolBar.items = [uiFlexibleSpace, uiDoneBarItem]
        
        messageTextView.inputAccessoryView = uiToolBar
        messageTextView.backgroundColor = .white
        messageTextView.textColor = .black
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 0.8)
        messageTextView.layer.cornerRadius = 10.0
    }

    private func addKeyboardObserverMethods() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        if self.bottomConstraint.constant != 0 {
            self.animateBottomView(constant: self.bottomConstraint.constant + keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.bottomConstraint.constant != 0 {
            self.animateBottomView(constant: 0)
        }
    }

}
