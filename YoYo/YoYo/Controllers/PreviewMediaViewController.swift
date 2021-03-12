//
//  PreviewMediaViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/12/21.
//

import UIKit
import AVKit

class PreviewMediaViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    var message:Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let message = message {
            if message.messageType == .IMAGE {
                imageView.sd_setImage(with: URL(string: message.assetURL!), completed: nil)
            }
        }
    }
    
}
