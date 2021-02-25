//
//  Story.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/25/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Story: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var title: String
    var expiryDate: Date
    var assetURL: String
    var viewedBy: [String]
}
