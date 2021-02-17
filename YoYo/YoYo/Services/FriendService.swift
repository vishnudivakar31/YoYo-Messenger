//
//  FriendService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import Foundation
import Firebase

protocol FetchFriendDelegate {
    func fetchSuccess(myFriends: [MyFriend])
    func fetchError(msg: String)
    func detectFriendsChange(status: Bool)
    func actionPerformed(status: Bool)
}

enum FRIEND_ACTION: String, Codable {
    case ACCEPT = "ACCEPT"
    case CANCEL = "CANCEL"
    case UNFRIEND = "UNFRIEND"
    case BLOCK = "BLOCK"
    case UNBLOCK = "UNBLOCK"
}

class FriendService {
    
    private let databaseService = DatabaseService()
    private let authenticationService = AuthenticationService()
    
    var fetchFriendDelegate: FetchFriendDelegate?
    
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
    
    func performActionForFriend(friendUID: String, action: FRIEND_ACTION) {
        let myUID = authenticationService.getUserID()!
        databaseService.fetchFriendsList(uid: myUID) { (friendsList, error) in
            if error != nil {
                self.fetchFriendDelegate?.actionPerformed(status: false)
            } else if var friendsList = friendsList {
                let friends = friendsList.friends
                if action == .BLOCK {
                    let modifiedFriends = self.performAction(friends: friends, friendUID: friendUID, action: action, blockedByMe: true)
                    friendsList.friends = modifiedFriends
                } else {
                    let modifiedFriends = self.performAction(friends: friends, friendUID: friendUID, action: action, blockedByMe: false)
                    friendsList.friends = modifiedFriends
                }
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    self.performActionWithFriend(myUID: friendUID, friendUID: myUID, action: action) { (success1) in
                        if success && success1 {
                            self.fetchFriendDelegate?.actionPerformed(status: true)
                        } else {
                            self.fetchFriendDelegate?.actionPerformed(status: false)
                        }
                    }
                }
            } else {
                self.fetchFriendDelegate?.actionPerformed(status: false)
            }
        }
    }
    
    private func performActionWithFriend(myUID: String, friendUID: String, action: FRIEND_ACTION, completionHandler: @escaping (_ success: Bool) -> ()) {
        databaseService.fetchFriendsList(uid: myUID) { (friendsList, error) in
            if error != nil {
                completionHandler(false)
            } else if var friendsList = friendsList {
                let friends = friendsList.friends
                let modifiedFriends = self.performAction(friends: friends, friendUID: friendUID, action: action, blockedByMe: false)
                friendsList.friends = modifiedFriends
                self.databaseService.updateFriendsList(friendsList: friendsList) { (success) in
                    completionHandler(success)
                }
            }
        }
    }
    
    private func performAction(friends: [Friend], friendUID: String, action: FRIEND_ACTION, blockedByMe: Bool) -> [Friend] {
        var newFriends = friends
        if action == .ACCEPT || action == .BLOCK || action == .UNBLOCK {
            for index in 0..<newFriends.count {
                if(newFriends[index].uid == friendUID) {
                    if action == FRIEND_ACTION.ACCEPT || action == FRIEND_ACTION.UNBLOCK {
                        newFriends[index].status = .ACCPETED
                    } else if action == FRIEND_ACTION.BLOCK && blockedByMe {
                        newFriends[index].status = .UNBLOCK
                    } else {
                        newFriends[index].status = .BLOCKED
                    }
                }
            }
        } else if action == .CANCEL || action == .UNFRIEND {
            var removingIndex = 0
            for index in 0..<newFriends.count {
                if(newFriends[index].uid == friendUID) {
                    removingIndex = index
                    break
                }
            }
            newFriends.remove(at: removingIndex)
        }
        return newFriends
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
    
    func fetchFriendsList() {
        let uid = authenticationService.getUserID()!
        databaseService.fetchFriendsList(uid: uid) { (friendsList, error) in
            if error != nil {
                self.fetchFriendDelegate?.fetchError(msg: error!.localizedDescription)
            } else if let friendsList = friendsList {
                let friends = friendsList.friends.filter { $0.status != FRIEND_STATUS.BLOCKED }
                let uids: [String] = friends.map { (friend) -> String in
                    return friend.uid
                }
                if uids.count > 0 {
                    self.databaseService.fetchUserModels(withUIDs: uids) { (userModels, error) in
                        if error != nil {
                            self.fetchFriendDelegate?.fetchError(msg: error!.localizedDescription)
                        } else if let userModels = userModels {
                            var myFriends: [MyFriend] = []
                            for friend in friends {
                                let userModel = userModels.filter { $0.userID == friend.uid }
                                let myFriend = MyFriend(friend: friend, userModel: userModel.first!)
                                myFriends.append(myFriend)
                            }
                            myFriends.sort { $0.friend.date > $1.friend.date }
                            self.fetchFriendDelegate?.fetchSuccess(myFriends: myFriends)
                        } else {
                            self.fetchFriendDelegate?.fetchError(msg: "unable to fetch friends list. try again later")
                        }
                    }
                } else {
                    self.fetchFriendDelegate?.fetchError(msg: "unable to fetch friends list. try again later")
                }
            } else {
                self.fetchFriendDelegate?.fetchError(msg: "unable to fetch friends list. try again later")
            }
        }
    }
    
    func registerForFriendsList() -> ListenerRegistration {
        databaseService.registrationFriendsListDelegate = self
        return databaseService.registerForFriendsList(uid: authenticationService.getUserID()!)
    }
    
}

// MARK:- Register friendslist delegate methods
extension FriendService: RegistrationForFriendsList {
    func changeDetected(status: Bool) {
        fetchFriendDelegate?.detectFriendsChange(status: status)
    }
}
