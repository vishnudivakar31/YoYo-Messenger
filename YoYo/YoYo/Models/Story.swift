//
//  Story.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/25/21.
//

import Foundation
import FirebaseFirestoreSwift

enum MEDIA_TYPE: String, Codable {
    case IMAGE = "IMAGE"
    case VIDEO = "VIDEO"
}

struct Story: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var title: String
    var expiryDate: Date
    var assetURL: String
    var viewedBy: [String]
    var mediaType: MEDIA_TYPE
}
