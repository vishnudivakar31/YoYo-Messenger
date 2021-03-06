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
    @IBOutlet weak var messageTxt: UILabel!
    @IBOutlet weak var messageStatusTxt: UILabel!
    @IBOutlet weak var messageTimeTxt: UILabel!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet var bubbleViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var bubbleViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var messageTimeTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var messageTimeLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoButton: UIImageView!
    
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
            messageStatusTxt.text = (message.messageStatus == MESSAGE_STATUS.SEND) ? "✓" : "✓✓"
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
            let assetURL = URL(string: message.thumbnailURL!)!
            mediaImageView.sd_setImage(with: assetURL, completed: nil)
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
            bubbleViewLeadingConstraint.isActive = false
            bubbleViewTrailingConstraint.isActive = true
            
            messageTimeLeadingConstraint.isActive = false
            messageTimeTrailingConstraint.isActive = true
            messageTimeTxt.textAlignment = .right
            
            messageBubbleView.backgroundColor = UIColor(cgColor: CGColor(red: 116/255, green: 185/255, blue: 1, alpha: 1))
        } else {
            bubbleViewLeadingConstraint.isActive = true
            bubbleViewTrailingConstraint.isActive = false
            
            messageTimeLeadingConstraint.isActive = true
            messageTimeTrailingConstraint.isActive = false

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
