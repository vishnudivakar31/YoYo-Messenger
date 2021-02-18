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
    
    var delegate: StorageDelegate?
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        get {
            storage.reference()
        }
    }
    
    func uploadImageToStorage(data: Data, fileName: String, userID: String) {
        let imageRef = storageRef.child("images")
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
    
    func removeImageFromStorage(imageURL: String, completionHandler: @escaping (_ status: Bool) -> ()) {
        storage.reference(forURL: imageURL).delete { (error) in
            if let _ = error {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
}
