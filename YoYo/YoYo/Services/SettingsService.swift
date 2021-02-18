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
}

class SettingsService {
    
    let databaseService = DatabaseService()
    let authenticationService = AuthenticationService()
    var delegate: SettingsDelegate?
    
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
}