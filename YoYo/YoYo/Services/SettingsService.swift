//
//  SettingsService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/18/21.
//

import Foundation

protocol SettingsDelegate {
    func fetchUserProfileSuccess(userModel: UserModel)
    func sendPasswordResetStatus(error: Error?)
    func changeNameStatus(status: Bool, error: Error?)
    func uploadImageStatus(status: Bool, msg: String)
}

class SettingsService {
    
    let databaseService = DatabaseService()
    let authenticationService = AuthenticationService()
    let storageService = StorageService()
    var delegate: SettingsDelegate?
    
    init() {
        storageService.delegate = self
    }
    
    func fetchUserProfile() {
        let uid = authenticationService.getUserID()!
        databaseService.fetchUserModel(userID: uid) { (userModel) in
            if let userModel = userModel {
                self.delegate?.fetchUserProfileSuccess(userModel: userModel)
            }
        }
    }
    
    func sendPasswordResetRequest(email: String) {
        authenticationService.sendPasswordReset(email: email) { (error) in
            self.delegate?.sendPasswordResetStatus(error: error)
        }
    }
    
    func logout() -> Bool {
        return authenticationService.logout()
    }
    
    func changeName(name: String) {
        let uid = authenticationService.getUserID()!
        databaseService.changeName(uid: uid, name: name) { (status, error) in
            self.delegate?.changeNameStatus(status: status, error: error)
        }
    }
    
    func changeProfilePhoto(imageData: Data, imageURL: String) {
        let userID = authenticationService.getUserID()!
        storageService.removeImageFromStorage(imageURL: imageURL) { (success) in
            if success {
                self.storageService.uploadImageToStorage(data: imageData, fileName: "profile_pic", userID: userID)
            } else {
                self.delegate?.uploadImageStatus(status: false, msg: "Cannot delete old picture. try again later.")
            }
        }
    }
}

// MARK:- Storage Service Delegate Methods
extension SettingsService: StorageDelegate {
    func uploadSuccessFull(url: String) {
        let userID = authenticationService.getUserID()!
        databaseService.updateProfileURL(uid: userID, imageURL: url) { (success, error) in
            if let error = error {
                self.delegate?.uploadImageStatus(status: false, msg: error.localizedDescription)
            } else {
                self.delegate?.uploadImageStatus(status: true, msg: "uploaded succesfully")
            }
        }
    }
    
    func uploadFailure(msg: String) {
        self.delegate?.uploadImageStatus(status: false, msg: msg)
    }
}
