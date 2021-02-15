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

class DatabaseService {
    private let db = Firestore.firestore()
    private let USER_COLLECTION = "users"
    var userModelDelegate: UserModelDelegate?
    
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
        
}
