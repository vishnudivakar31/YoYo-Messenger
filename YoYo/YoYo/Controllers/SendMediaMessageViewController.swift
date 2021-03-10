//
//  SendMediaMessageViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/10/21.
//

import UIKit

class SendMediaMessageViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageImageView: UIImageView!
    
    var uploadAsset: UploadAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSendButtonTapped(_ sender: Any) {
    }
    
}
