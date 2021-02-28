//
//  StoryService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/27/21.
//

import Foundation

protocol StoryDelegate {
    func fetchMyStory(stories: [Story]?, error: Error?)
    func fetchFriendsStory(stories: [FriendStory]?, error: Error?)
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
    
}
