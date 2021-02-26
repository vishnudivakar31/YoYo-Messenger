//
//  UploadImageStoryViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/26/21.
//

import UIKit

class UploadImageStoryViewController: UIViewController {

    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var assetData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputStackView.layer.cornerRadius = 5.0
        
        if let assetData = assetData {
            storyImageView.image = UIImage(data: assetData)
        }
        
    }
    
    @IBAction func uploadTapped(_ sender: Any) {
    }
    
}
