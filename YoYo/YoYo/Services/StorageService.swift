//
//  StorageService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/8/21.
//

import Foundation
import Firebase

public protocol StorageDelegate {
    func uploadSuccessFull(url: String)
    func uploadFailure(msg: String)
}

class StorageService {
    
    private let IMAGES_REF = "images"
    private let STORY_REF = "stories"
    private let MEDIA_REF = "media"
    
    var delegate: StorageDelegate?
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        get {
            storage.reference()
        }
    }
    
    func uploadImageToStorage(data: Data, fileName: String, userID: String) {
        let imageRef = storageRef.child(IMAGES_REF)
        let pictureName = "\(userID)_\(NSTimeIntervalSince1970)_\(fileName).jpg"
        let pictureRef = imageRef.child(pictureName)
        pictureRef.putData(data, metadata: nil) {(_, error) in
            if error != nil {
                self.delegate?.uploadFailure(msg: error?.localizedDescription ?? "")
            } else {
                pictureRef.downloadURL { (url, downloadError) in
                    guard let url = url, downloadError == nil else {
                        self.delegate?.uploadFailure(msg: downloadError?.localizedDescription ?? "")
                        return
                    }
                    if downloadError == nil {
                        self.delegate?.uploadSuccessFull(url: url.absoluteString)
                    }
                }
            }
        }
    }
    
    func uploadStory(data: Data, mediaType: MEDIA_TYPE,fileName: String, userID: String, completionHandler: @escaping (_ url: String?, _ error: Error?) -> ()) {
        let storyRef = storageRef.child(STORY_REF)
        let storyName = "\(userID)_\(NSTimeIntervalSince1970)_\(fileName).\(mediaType == .IMAGE ? "jpg" : "mp4")"
        let ref = storyRef.child(storyName)
        ref.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                ref.downloadURL { (url, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else {
                        completionHandler(url?.absoluteString, nil)
                    }
                }
            }
        }
    }
    
    func removeImageFromStorage(imageURL: String, completionHandler: @escaping (_ status: Bool) -> ()) {
        storage.reference(forURL: imageURL).delete { (error) in
            if let _ = error {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    func uploadMedia(data: Data, mediaType: MEDIA_TYPE, fileName: String, userID: String, completionHandler: @escaping (_ url: String?, _ error: Error?) -> ()) {
        let mediaRef = storageRef.child(MEDIA_REF)
        let mediaName = "\(userID)_\(NSTimeIntervalSince1970)_\(fileName).\(mediaType == .IMAGE ? "jpg" : "mp4")"
        let ref = mediaRef.child(mediaName)
        ref.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                ref.downloadURL { (url, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else {
                        completionHandler(url?.absoluteString, nil)
                    }
                }
            }
        }
    }
    
}
