//
//  File.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import Foundation
import FirebaseFirestoreSwift

enum MESSAGE_TYPE: String, Codable {
    case PLAIN = "PLAIN"
    case MEDIA = "MEDIA"
}

enum MESSAGE_STATUS: String, Codable {
    case SEND = "SEND"
    case SEEN = "SEEN"
}

struct Message: Codable, Identifiable {
    @DocumentID var id: String?
    let senderID: String
    let receiverID: String
    let date: Date
    let messageType: MESSAGE_TYPE
    let messageStatus: MESSAGE_STATUS
    let message: String?
    let assetURL: String?
}
