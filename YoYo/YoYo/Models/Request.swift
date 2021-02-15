//
//  Request.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit
import FirebaseFirestoreSwift

public enum RequestStatus: String, Codable {
    case INITIATED = "INITIATED"
    case ACCEPTED = "ACCEPTED"
    case CANCELLED = "CANCELLED"
}

struct Request: Codable, Identifiable {
    @DocumentID var id: String?
    var initiatedBy: String
    var requestedTo: String
    var message: String
    var date: Date
    var status: RequestStatus
}
