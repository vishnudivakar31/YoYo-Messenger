//
//  MessagingService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import Foundation

protocol MessageServiceDelegate {
    func getMyFriendsCompleted(friends: [UserModel]?, error: Error?)
}

class MessagingService {
    
    private let authenticationService = AuthenticationService()
    private let databaseService = DatabaseService()
    
    var delegate:MessageServiceDelegate?
    
    func getMyFriends() {
        let uid = authenticationService.getUserID()!
        databaseService.fetchFriendsList(uid: uid) { (friendsList, error) in
            if error != nil {
                self.delegate?.getMyFriendsCompleted(friends: nil, error: error)
            } else if let friendsList = friendsList {
                let uids: [String] = friendsList.friends.compactMap { return $0.uid }
                self.databaseService.fetchUserModels(withUIDs: uids) { (userModel, error) in
                    self.delegate?.getMyFriendsCompleted(friends: userModel, error: error)
                }
            }
        }
    }
    
    func sendMessage(msg: String?, receiverID: String, messageType: MESSAGE_TYPE, assetURL: String, completionHandler: (_ success: Bool, _ msg: String?) -> ()) {
        let uid = authenticationService.getUserID()!
        let message = Message(senderID: uid, receiverID: receiverID, date: Date(), messageType: messageType, messageStatus: MESSAGE_STATUS.SEND, message: msg, assetURL: assetURL)
        databaseService.saveMessage(message) { (success, msg) in
            completionHandler(success, msg)
        }
    }
    
}
