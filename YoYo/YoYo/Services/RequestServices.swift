//
//  RequestServices.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import Foundation

class RequestServices {
    
    private let authenticationService = AuthenticationService()
    private let databaseService = DatabaseService()
    
    func sendAddFriendRequest(email: String, msg: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        let userID = authenticationService.getUserID()
        databaseService.fetchUID(withEmail: email) { (targetUID) in
            if targetUID != nil && userID != nil {
                let request = Request(initiatedBy: userID!, requestedTo: targetUID!, message: msg, date: Date(), status: RequestStatus.INITIATED)
                self.databaseService.saveRequest(request: request) { (uid) in
                    if uid != nil {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            }
        }
    }
}
