//
//  PreviewVideoViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/12/21.
//

import UIKit
import AVKit

class PreviewVideoViewController: AVPlayerViewController {

    var message: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let message = message {
            self.player = AVPlayer(url: URL(string: message.assetURL!)!)
            self.player?.play()
        }
    }

}
