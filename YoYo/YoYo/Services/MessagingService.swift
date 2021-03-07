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
}
