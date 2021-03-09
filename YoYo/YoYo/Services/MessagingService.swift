//
//  MessagingService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import Foundation
import Firebase

protocol MessageServiceDelegate {
    func getMyFriendsCompleted(friends: [UserModel]?, error: Error?)
    func newMessageDetected(newMessages: [Message], msg: String)
    func fetchMessagesCompleted(messages: [Message], error: Error?)
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
    
    func sendMessage(msg: String?, receiverID: String, messageType: MESSAGE_TYPE, assetURL: String?, completionHandler: @escaping (_ success: Bool, _ msg: String?) -> ()) {
        let uid = authenticationService.getUserID()!
        let message = Message(senderID: uid, receiverID: receiverID, date: Date(), messageType: messageType, messageStatus: MESSAGE_STATUS.SEND, message: msg, assetURL: assetURL)
        databaseService.saveMessage(message) { (success, msg) in
            completionHandler(success, msg)
        }
    }
    
    func fetchMessages(receiverID: String) {
        let uid = authenticationService.getUserID()!
        databaseService.fetchMessages(myUID: uid, receiverUID: receiverID) { (messages, error) in
            self.delegate?.fetchMessagesCompleted(messages: messages, error: error)
        }
    }
    
    func registerForMessages(uid: String) -> [ListenerRegistration] {
        databaseService.messageDelegate = self
        let myUID = authenticationService.getUserID()!
        return databaseService.registerForMessageCollection(myUID: myUID, friendUID: uid)
    }
    
    func getMyUID() -> String {
        return authenticationService.getUserID()!
    }
    
}

// MARK:- REGISTER FOR MESSAGE
extension MessagingService: MessageDelegate {
    func newMessagesAdded(messages: [Message], msg: String) {
        self.delegate?.newMessageDetected(newMessages: messages, msg: msg)
    }
}
