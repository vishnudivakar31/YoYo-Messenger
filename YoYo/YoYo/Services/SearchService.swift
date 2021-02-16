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
            if error != nil {
                self.delegate?.searchCompleted(profiles: nil, error: error)
            } else {
                self.databaseService.fetchFriendsList(uid: uid!) { (friendsList, error) in
                    if let friendsList = friendsList {
                        let friends = friendsList.friends
                        let filteredResult = profiles?.filter({ (profile) -> Bool in
                            return !friends.contains(where: { friend in friend.uid == profile.userID})
                        })
                        self.delegate?.searchCompleted(profiles: filteredResult, error: error)
                    } else {
                        self.delegate?.searchCompleted(profiles: profiles, error: error)
                    }
                }
            }
        }
    }
}
