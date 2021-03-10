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
    func modifiedMessageDetected(modifiedMessages: [Message], msg: String)
    func fetchMessagesCompleted(messages: [Message], error: Error?)
}

protocol ChatServiceDelegate {
    func fetchChatModels(chatModels: [ChatModel], error: Error?)
    func chatModelChanged(success: Bool, error: Error?)
}

class MessagingService {
    
    private let authenticationService = AuthenticationService()
    private let databaseService = DatabaseService()
    private let storageService = StorageService()
    
    var delegate:MessageServiceDelegate?
    var chatDelegate: ChatServiceDelegate?
    
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
    
    func sendMessageUsing(message: Message, completionHandler: @escaping (_ success: Bool, _ msg: String?) -> ()) {
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
    
    func changeMessageStatusToSeen(messages: [Message]) -> [Message] {
        let uid = getMyUID()
        var filteredMessages: [Message] = messages.filter { $0.receiverID == uid && $0.messageStatus == .SEND }
        for i in 0..<filteredMessages.count {
            filteredMessages[i].messageStatus = .SEEN
        }
        databaseService.updateMessageToSeen(messages: filteredMessages)
        return filteredMessages
    }
    
    func getMyUID() -> String {
        return authenticationService.getUserID()!
    }
    
    func fetchChatModels() {
        databaseService.messageDelegate = self
        let uid = authenticationService.getUserID()!
        databaseService.fetchMessagesForChatView(myUID: uid)
    }
    
    func uploadMedia(data: Data, mediaType: MEDIA_TYPE, fileName: String, userID: String, completionHandler: @escaping (_ url: String?, _ error: Error?) -> ()) {
        storageService.uploadMedia(data: data, mediaType: mediaType, fileName: fileName, userID: userID) { (url, error) in
            completionHandler(url, error)
        }
    }
    
    func registerForChatModelChange() -> [ListenerRegistration] {
        let uid = authenticationService.getUserID() ?? ""
        if uid.count > 0 {
            return databaseService.registerForChatModelChanges(myUID: uid)
        }
        return []
    }
    
}

// MARK:- REGISTER FOR MESSAGE
extension MessagingService: MessageDelegate {
    func chatModelChangesDetected(success: Bool, error: Error?) {
        self.chatDelegate?.chatModelChanged(success: success, error: error)
    }
    
    func fetchMessagesForChatView(messages: [Message], error: Error?) {
        if error == nil {
            let myUID = authenticationService.getUserID()!
            var userIDs: Set<String> = []
            for message in messages {
                if myUID != message.senderID {
                    userIDs.insert(message.senderID)
                } else {
                    userIDs.insert(message.receiverID)
                }
            }
            var chatModels: [ChatModel] = []
            databaseService.fetchUserModels(withUIDs: [String](userIDs)) { (userModels, error) in
                if error != nil {
                    self.chatDelegate?.fetchChatModels(chatModels: [], error: error)
                } else if let userModels = userModels {
                    for userModel in userModels {
                        let unSeenMessageCount: Int = messages.filter { $0.senderID == userModel.userID && $0.messageStatus == MESSAGE_STATUS.SEND }.count
                        let lastDate: Date = messages.filter { $0.senderID == userModel.userID || $0.receiverID == userModel.userID }.compactMap { return $0.date }.max()!
                        chatModels.append(ChatModel(userModel: userModel, unSeenMessages: unSeenMessageCount, lastMessageDate: lastDate))
                    }
                    chatModels = chatModels.sorted { $0.lastMessageDate > $1.lastMessageDate }
                    self.chatDelegate?.fetchChatModels(chatModels: chatModels, error: nil)
                }
            }
        } else {
            self.chatDelegate?.fetchChatModels(chatModels: [], error: error)
        }
    }
    
    func modifiedMessagesDetected(modifiedMessages: [Message], msg: String) {
        self.delegate?.modifiedMessageDetected(modifiedMessages: modifiedMessages, msg: msg)
    }
    
    func newMessagesAdded(messages: [Message], msg: String) {
        self.delegate?.newMessageDetected(newMessages: messages, msg: msg)
    }
}
