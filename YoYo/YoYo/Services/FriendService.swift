//
//  FriendService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import Foundation

class FriendService {
    
    private let databaseService = DatabaseService()
    
    func sendFriendRequest(myUID: String, friendUID: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        databaseService.fetchFriendsList(uid: myUID) { (friendsList, error) in
            if error != nil {
                completionHandler(false)
            } else if var friendsList = friendsList {
                let friend = Friend(uid: friendUID, date: Date(), status: FRIEND_STATUS.REQUEST_SEND)
                friendsList.friends.append(friend)
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    self.createFriendRequestForFriend(myUID: myUID, friendUID: friendUID) { (success1) in
                        completionHandler(success && success1)
                    }
                }
            } else {
                let friend = Friend(uid: friendUID, date: Date(), status: FRIEND_STATUS.REQUEST_SEND)
                var friendsList = FriendsList(uid: myUID, friends: [])
                friendsList.friends.append(friend)
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    self.createFriendRequestForFriend(myUID: myUID, friendUID: friendUID) { (success1) in
                        completionHandler(success && success1)
                    }
                }
            }
        }
    }
    
    private func createFriendRequestForFriend(myUID: String, friendUID: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        databaseService.fetchFriendsList(uid: friendUID) { (friendsList, error) in
            if error != nil {
                completionHandler(false)
            } else if var friendsList = friendsList {
                let friend = Friend(uid: myUID, date: Date(), status: FRIEND_STATUS.REQUESTED)
                friendsList.friends.append(friend)
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    completionHandler(success)
                }
            } else {
                let friend = Friend(uid: myUID, date: Date(), status: FRIEND_STATUS.REQUESTED)
                var friendsList = FriendsList(uid: friendUID, friends: [])
                friendsList.friends.append(friend)
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    completionHandler(success)
                }
            }
        }
    }
    
}
