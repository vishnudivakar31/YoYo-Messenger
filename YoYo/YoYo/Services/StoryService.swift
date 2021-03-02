//
//  StoryService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/27/21.
//

import Foundation
import Firebase

protocol StoryDelegate {
    func fetchMyStory(stories: [Story]?, error: Error?)
    func fetchFriendsStory(stories: [FriendStory]?, error: Error?)
    func registerForStories(listener: ListenerRegistration)
    func changeDetected(status: Bool)
}

class StoryService {
    
    private let authenticationService = AuthenticationService()
    private let storageService = StorageService()
    private let databaseService = DatabaseService()
    
    var delegate: StoryDelegate?
    
    func uploadStory(uploadAsset: UploadAsset, title: String, completionHandler: @escaping (_ success: Bool, _ msg: String) -> ()) {
        let uid = authenticationService.getUserID()!
        storageService.uploadStory(data: uploadAsset.data, mediaType: uploadAsset.mediaType, fileName: title, userID: uid) { (optionalURL, error) in
            if let error = error {
                completionHandler(false, error.localizedDescription)
            } else if let url = optionalURL{
                let expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                let story = Story(uid: uid, title: title, expiryDate: expiryDate, assetURL: url, viewedBy: [], mediaType: uploadAsset.mediaType)
                self.databaseService.saveStory(story) { (success, msg) in
                    completionHandler(success, msg ?? "try again later")
                }
            } else {
                completionHandler(false, "try again later")
            }
        }
    }
    
    func fetchMyStories() {
        let uid = authenticationService.getUserID()!
        databaseService.getStoryWithUID(uid) { (stories, error) in
            self.delegate?.fetchMyStory(stories: stories, error: error)
        }
    }
    
    func fetchUserModel(uid: String?, completionHandler: @escaping (_ userModel: UserModel?) -> ()) {
        if let uid = uid {
            databaseService.fetchUserModel(userID: uid) { (userModel) in
                completionHandler(userModel)
            }
        } else {
            let myUID = authenticationService.getUserID()!
            databaseService.fetchUserModel(userID: myUID) { (userModel) in
                completionHandler(userModel)
            }
        }
    }
    
    func fetchUserModels(uids: [String], completionHandler: @escaping (_ userModels: [UserModel]?, _ error: Error?) -> ()) {
        databaseService.fetchUserModels(withUIDs: uids) { (userModels, error) in
            completionHandler(userModels, error)
        }
    }
    
    func fetchMyUserModel(completionHandler: @escaping (_ userModel: UserModel?) -> ()) {
        let uid = authenticationService.getUserID()!
        self.fetchUserModel(uid: uid) { (userModel) in
            completionHandler(userModel)
        }
    }
    
    func fetchMyFriendsStories() {
        let uid = authenticationService.getUserID()!
        databaseService.fetchFriendsList(uid: uid) { (friendsList, error) in
            if let error = error {
                self.delegate?.fetchFriendsStory(stories: [], error: error)
            } else if let friendsList = friendsList {
                let friends = friendsList.friends.filter { $0.status == .ACCPETED }
                let uids: [String] = friends.compactMap { return $0.uid }
                self.databaseService.fetchUserModels(withUIDs: uids) { (userModels, error) in
                    if let error = error {
                        self.delegate?.fetchFriendsStory(stories: [], error: error)
                    } else if let userModels = userModels {
                        self.databaseService.getStoriesWithUID(uids) { (stories, error) in
                            if let error = error {
                                self.delegate?.fetchFriendsStory(stories: [], error: error)
                            } else if let stories = stories {
                                var friendsStory: [FriendStory] = []
                                for uid in uids {
                                    let userModel = userModels.filter { $0.userID == uid}.first!
                                    let userStories = stories.filter { $0.uid == uid }
                                    friendsStory.append(FriendStory(userModel: userModel, stories: userStories))
                                }
                                friendsStory = friendsStory.filter { $0.stories?.count ?? 0 > 0 }
                                self.delegate?.fetchFriendsStory(stories: friendsStory, error: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func registerForStories() {
        let uid = authenticationService.getUserID()!
        databaseService.registrationForStoriesDelegate = self
        databaseService.fetchFriendsList(uid: uid) { (friendsList, error) in
            if let friendsList = friendsList {
                var uids: [String] = friendsList.friends.compactMap { return $0.uid }
                uids.append(uid)
                let listener = self.databaseService.registerForStories(uids: uids)
                self.delegate?.registerForStories(listener: listener)
            }
        }
    }
    
    func addViews(story: Story, completionHandler: @escaping (_ error: Error?) -> ()) {
        let uid = authenticationService.getUserID()!
        if uid != story.uid && !story.viewedBy.contains(uid) {
            var updatedStory = story
            updatedStory.viewedBy.append(uid)
            databaseService.updateStory(story: updatedStory) { (error) in
                completionHandler(error)
            }
        }
    }
    
    func getMyUID() -> String? {
        return authenticationService.getUserID()
    }

}

// MARK:- Registration for stories delegate
extension StoryService: RegistrationForStories {
    func changeDetected(status: Bool) {
        self.delegate?.changeDetected(status: status)
    }
}
