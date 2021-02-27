//
//  StoryService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/27/21.
//

import Foundation

protocol StoryDelegate {
    func fetchMyStory(stories: [Story]?, error: Error?)
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
    
}
