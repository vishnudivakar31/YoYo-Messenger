//
//  UserModel.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/9/21.
//

import Foundation
import FirebaseFirestoreSwift

struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var dob: Date
    var profilePictureURL: String
    var userID: String
}
