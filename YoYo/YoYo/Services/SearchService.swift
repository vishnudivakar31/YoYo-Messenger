//
//  SearchService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import Foundation

protocol SearchDelegate {
    func searchCompleted(profiles: [UserModel]?, error: Error?)
}

class SearchService {
    
    private let databaseService = DatabaseService()
    private let authenticationService = AuthenticationService()
    var delegate: SearchDelegate?
    
    func searchUserProfiles(searchString: String) {
        let uid = authenticationService.getUserID()
        databaseService.fetchUserProfiles(uid: uid!, withSearchString: searchString) { (profiles, error) in
            self.delegate?.searchCompleted(profiles: profiles, error: error)
        }
    }
}
