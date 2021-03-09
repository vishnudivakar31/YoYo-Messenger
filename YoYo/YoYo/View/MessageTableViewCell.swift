//
//  MessageTableViewCell.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/8/21.
//

import UIKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageBubbleView: UIStackView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var messageTxt: UILabel!
    @IBOutlet weak var messageStatusTxt: UILabel!
    @IBOutlet weak var messageTimeTxt: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    
    var messageTrailingConstraint: NSLayoutConstraint!
    var messageLeadingConstraint: NSLayoutConstraint!
    
    var timeTrailingConstraint: NSLayoutConstraint!
    var timeLeadingConstraint: NSLayoutConstraint!
    
    var message: Message?
    var myUID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawCell()
    }
    
    public func drawCell() {
        setupView()
        if let myUID = myUID, let message = message {
            self.hideComponents(message: message)
            setMessageWidth(message: message.message ?? "")
            messageTxt.text = message.message
            messageStatusTxt.text = message.messageStatus.rawValue
            setMessageTime(message: message)
            setSenderViewOrReceiverView(myUID: myUID, message: message)
            setAssetImage(message: message)
        }
    }
    
    private func setMessageWidth(message: String) {
        messageTxt.numberOfLines = 0
        messageTxt.lineBreakMode = .byWordWrapping
    }
    
    private func setAssetImage(message: Message) {
        if message.messageType != .PLAIN {
            let assetURL = URL(string: message.assetURL!)!
            if message.messageType == .IMAGE {
                mediaImageView.sd_setImage(with: assetURL, completed: nil)
            } else {
                let asset = AVAsset(url: assetURL)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                do {
                    let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
                    mediaImageView.image = UIImage(cgImage: thumbnailImage)
                    } catch let error {
                        print(error)
                    }
            }
        }
    }
    
    private func setupView() {
        messageBubbleView.isHidden = false
        mediaView.isHidden = false
        videoButton.isHidden = false
        messageTxt.isHidden = false
        messageStatusTxt.isHidden = false
        messageTimeTxt.isHidden = false
        
        videoButton.layer.cornerRadius = 15
        
        messageBubbleView.layer.cornerRadius = 10.0
        
        messageTrailingConstraint = messageBubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        messageLeadingConstraint = messageBubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
        
        timeTrailingConstraint = messageTimeTxt.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        timeLeadingConstraint = messageTimeTxt.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        
        messageTrailingConstraint.isActive = false
        messageLeadingConstraint.isActive = false
        timeTrailingConstraint.isActive = false
        timeLeadingConstraint.isActive = false
    }
    
    private func setMessageTime(message: Message) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        if calendar.isDateInToday(message.date) {
            dateFormatter.dateFormat = "h:mm a"
        } else {
            dateFormatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        }
        messageTimeTxt.text = dateFormatter.string(from: message.date)
    }
    
    private func setSenderViewOrReceiverView(myUID: String, message: Message) {
        if myUID == message.senderID {
            messageTrailingConstraint.isActive = true
            timeTrailingConstraint.isActive = true
            messageBubbleView.backgroundColor = UIColor(cgColor: CGColor(red: 116/255, green: 185/255, blue: 1, alpha: 1))
        } else {
            messageLeadingConstraint.isActive = true
            timeLeadingConstraint.isActive = true
            messageBubbleView.backgroundColor = .lightGray
            messageStatusTxt.isHidden = true
        }
    }
    
    private func hideComponents(message: Message) {
        if message.messageType == .PLAIN {
            mediaView.isHidden = true
        } else if message.messageType == .IMAGE {
            videoButton.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
