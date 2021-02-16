//
//  FriendsViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/16/21.
//

import UIKit

class FriendsViewController: UIViewController {

    private let friendService = FriendService()
    private var myFriends: [MyFriend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendService.fetchFriendDelegate = self
        friendService.fetchFriendsList()
    }
}

// MARK:- FriendService Delegate methods
extension FriendsViewController: FetchFriendDelegate {
    func fetchSuccess(myFriends: [MyFriend]) {
        self.myFriends = myFriends
    }
    
    func fetchError(msg: String) {
        print(msg)
    }
    
    
}
