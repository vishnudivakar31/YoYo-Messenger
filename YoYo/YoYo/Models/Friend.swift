//
//  Friend.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import Foundation

enum FRIEND_STATUS: String, Codable {
    case REQUEST_SEND = "REQUEST_SEND"
    case REQUESTED = "REQUESTED"
    case ACCPETED = "ACCPETED"
    case BLOCKED = "BLOCKED"
}

struct Friend: Codable {
    var uid: String
    var date:Date
    var status: FRIEND_STATUS
}
