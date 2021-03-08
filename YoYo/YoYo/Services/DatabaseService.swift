//
//  DatabaseService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/8/21.
//

import Foundation
import Firebase

protocol UserModelDelegate {
    func saveUserModelSuccessful(user: UserModel, documentID: String)
    func saveUserModelFailed(msg: String)
}

protocol RegistrationForFriendsList {
    func changeDetected(status: Bool)
}

protocol RegistrationForStories {
    func changeDetected(status: Bool)
}

class DatabaseService {
    private let db = Firestore.firestore()
    private let USER_COLLECTION = "users"
    private let FRIENDS_COLLECTION = "friends"
    private let STORY_COLLECTION = "stories"
    private let MESSAGE_COLLECTION = "messages"
    var userModelDelegate: UserModelDelegate?
    var registrationFriendsListDelegate: RegistrationForFriendsList?
    var registrationForStoriesDelegate: RegistrationForStories?
    
    public func saveUserModel(user: UserModel) {
        do {
            let result = try db.collection(USER_COLLECTION).addDocument(from: user)
            userModelDelegate?.saveUserModelSuccessful(user: user, documentID: result.documentID)
        } catch {
            userModelDelegate?.saveUserModelFailed(msg: error.localizedDescription)
        }
    }
    
    public func fetchUserModel(userID: String, completionHandler: @escaping (_ userModel: UserModel?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userID", isEqualTo: userID).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(nil)
            } else if let snapshot = snapshot {
                let users: [UserModel] = snapshot.documents.compactMap { return try? $0.data(as: UserModel.self) }
                users.count > 0 ? completionHandler(users.first) : completionHandler(nil)
            }
        }
    }
    
    public func fetchUID(withEmail: String, completionHandler: @escaping (_ uid: String?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userEmail", isEqualTo: withEmail).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(nil)
            } else if let snapshot = snapshot {
                let users: [UserModel] = snapshot.documents.compactMap {return try? $0.data(as: UserModel.self)}
                users.count > 0 ? completionHandler(users.first?.userID) : completionHandler(nil)
            }
        }
    }
    
    public func fetchUserProfiles(uid: String, withSearchString: String, completionHandler: @escaping (_ profiles: [UserModel]?, _ error: Error?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userID", isNotEqualTo: uid).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(nil, error)
            } else if let snapshot = snapshot {
                var profiles: [UserModel] = snapshot.documents.compactMap { return try? $0.data(as: UserModel.self) }
                profiles = profiles.filter { $0.name.lowercased().contains(withSearchString.lowercased()) || $0.userEmail.contains(withSearchString.lowercased())}
                completionHandler(profiles, nil)
            }
        }
    }
    
    public func fetchFriendsList(uid: String, completionHandler: @escaping (_ friendsList: FriendsList?, _ error: Error?) -> ()) {
        db.collection(FRIENDS_COLLECTION).whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(nil, error)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                let friendsLists: [FriendsList] = snapshot.documents.compactMap { return try? $0.data(as: FriendsList.self) }
                if friendsLists.count > 0 {
                    completionHandler(friendsLists.first, nil)
                } else {
                    completionHandler(nil, nil)
                }
            } else {
                completionHandler(nil, nil)
            }
        }
    }
    
    public func updateFriendsList(friendsList: FriendsList, completionHandler: @escaping (_ success: Bool) -> ()) {
        db.collection(FRIENDS_COLLECTION).whereField("uid", isEqualTo: friendsList.uid).limit(to: 1).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(false)
            } else if let snapshot = snapshot {
                if snapshot.documents.isEmpty {
                    do {
                        let _ = try self.db.collection(self.FRIENDS_COLLECTION).addDocument(from: friendsList)
                        completionHandler(true)
                    } catch {
                        completionHandler(false)
                    }
                } else {
                    //snapshot.documents.first?.reference.updateData(["friends" : friendsList.friends])
                    if let documentID = friendsList.id {
                        do {
                            try self.db.collection(self.FRIENDS_COLLECTION).document(documentID).setData(from: friendsList)
                            completionHandler(true)
                        } catch {
                            completionHandler(false)
                        }
                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
    }
    
    public func registerForFriendsList(uid: String) -> ListenerRegistration {
        let listener = db.collection(FRIENDS_COLLECTION).whereField("uid", isEqualTo: uid).addSnapshotListener { (querySnapshot, error) in
            if error != nil {
                self.registrationFriendsListDelegate?.changeDetected(status: false)
            } else if let _ = querySnapshot {
                self.registrationFriendsListDelegate?.changeDetected(status: true)
            } else {
                self.registrationFriendsListDelegate?.changeDetected(status: true)
            }
        }
        return listener
    }
    
    public func registerForStories(uids: [String]) -> ListenerRegistration {
        let listener = db.collection(STORY_COLLECTION).whereField("uid", in: uids).addSnapshotListener { (querySnapshot, error) in
            if let _ = error {
                self.registrationForStoriesDelegate?.changeDetected(status: false)
            } else {
                self.registrationForStoriesDelegate?.changeDetected(status: true)
            }
        }
        return listener
    }
    
    public func fetchUserModels(withUIDs: [String], completionHandler: @escaping (_ userModels: [UserModel]?, _ error: Error?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userID", in: withUIDs).getDocuments { (snapshot, error) in
            if error != nil {
                completionHandler(nil, error)
            } else if let snapshot = snapshot {
                let userModel: [UserModel] = snapshot.documents.compactMap { return try? $0.data(as: UserModel.self)}
                completionHandler(userModel, nil)
            } else {
                completionHandler(nil, nil)
            }
        }
    }
    
    public func changeName(uid: String, name: String, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userID", isEqualTo: uid).limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(false, error)
            } else if let snapshot = snapshot {
                let userProfiles: [UserModel] = snapshot.documents.compactMap { return try? $0.data(as: UserModel.self) }
                var myProfile = userProfiles.first!
                myProfile.name = name
                do {
                    try self.db.collection(self.USER_COLLECTION).document(myProfile.id!).setData(from: myProfile)
                    completionHandler(true, nil)
                } catch {
                    completionHandler(false, error)
                }
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
    public func updateProfileURL(uid: String, imageURL: String, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> ()) {
        db.collection(USER_COLLECTION).whereField("userID", isEqualTo: uid).limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(false, error)
            } else if let snapshot = snapshot {
                let userProfiles: [UserModel] = snapshot.documents.compactMap { return try? $0.data(as: UserModel.self) }
                var myProfile = userProfiles.first!
                myProfile.profilePictureURL = imageURL
                do {
                    try self.db.collection(self.USER_COLLECTION).document(myProfile.id!).setData(from: myProfile)
                    completionHandler(true, nil)
                } catch {
                    completionHandler(false, error)
                }
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
    public func saveStory(_ story: Story, completionHandler: @escaping (_ success: Bool, _ msg: String?) -> ()) {
        do {
            let _ = try db.collection(STORY_COLLECTION).addDocument(from: story)
            completionHandler(true, "Successfully uploaded.")
        } catch {
            completionHandler(false, error.localizedDescription)
        }
    }
    
    public func saveMessage(_ message: Message, completionHandler: @escaping (_ success: Bool, _ msg: String?) -> ()) {
        do {
            let _ = try db.collection(MESSAGE_COLLECTION).addDocument(from: message)
            completionHandler(true, "message saved successfully")
        } catch {
            completionHandler(false, error.localizedDescription)
        }
    }
    
    public func getStoryWithUID(_ uid: String, completionHandler: @escaping (_ stories: [Story]?, _ error: Error?) -> ()) {
        db.collection(STORY_COLLECTION).whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler([], error)
            } else if let snapshot = snapshot {
                let today = Date()
                var stories: [Story] = snapshot.documents.compactMap { return try? $0.data(as: Story.self) }
                stories = stories.filter { today <= $0.expiryDate }
                completionHandler(stories, nil)
            } else {
                completionHandler([], nil)
            }
        }
    }
    
    public func getStoriesWithUID(_ uid: [String], completionHandler: @escaping (_ stories: [Story]?, _ error: Error?) -> ()) {
        db.collection(STORY_COLLECTION).whereField("uid", in: uid).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler([], error)
            } else if let snapshot = snapshot {
                let today = Date()
                var stories: [Story] = snapshot.documents.compactMap { return try? $0.data(as: Story.self) }
                stories = stories.filter { today <= $0.expiryDate }
                completionHandler(stories, nil)
            } else {
                completionHandler([], nil)
            }
        }
    }
    
    public func updateStory(story: Story, completionHandler: @escaping (_ error: Error?) -> ()) {
        do {
            try db.collection(STORY_COLLECTION).document(story.id!).setData(from: story)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
        
}
