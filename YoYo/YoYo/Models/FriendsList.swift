//
//  FriendsList.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import Foundation
import FirebaseFirestoreSwift

struct FriendsList: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var friends: [Friend]
}
