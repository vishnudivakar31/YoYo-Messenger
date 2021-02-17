//
//  FriendsViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/16/21.
//

import UIKit
import SDWebImage
import Firebase

class FriendsViewController: UIViewController {

    private let friendService = FriendService()
    private var myFriends: [MyFriend] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        friendService.fetchFriendDelegate = self
        listener = friendService.registerForFriendsList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let listener = self.listener {
            listener.remove()
        }
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "MyFriendViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MyFriendViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = 140
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- FriendService Delegate methods
extension FriendsViewController: FetchFriendDelegate {
    func actionPerformed(status: Bool) {
        if !status {
            presentAlert(title: "Alert", msg: "Unable to perform the action right now. Try again later.")
        }
    }
    
    func detectFriendsChange(status: Bool) {
        if status {
            friendService.fetchFriendsList()
        }
    }
    
    func fetchSuccess(myFriends: [MyFriend]) {
        self.myFriends = myFriends
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchError(msg: String) {
        presentAlert(title: "Alert", msg: msg)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK:- Tableview delgate methods
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myFriend = myFriends[indexPath.row]
        let friend = myFriend.friend
        let userModel = myFriend.userModel
        let diffDate = Calendar.current.dateComponents([.day], from: friend.date, to: Date()).day!
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendViewCell", for: indexPath) as! MyFriendViewCell
        cell.uid = userModel.userID
        cell.nameTextLabel.text = userModel.name
        cell.emailTextLabel.text = userModel.userEmail
        cell.profileImageView.sd_setImage(with: URL(string: userModel.profilePictureURL), completed: nil)
        cell.sinceLabel.text = "\(diffDate) days ago"
        
        cell.acceptButton.isHidden = false
        cell.blockButton.isHidden = false
        cell.cancelButton.isHidden = false
        cell.unfriendButton.isHidden = false
        cell.unblockButton.isHidden = false
        
        if friend.status == FRIEND_STATUS.REQUESTED {
            cell.blockButton.isHidden = true
            cell.unfriendButton.isHidden = true
            cell.unblockButton.isHidden = true
        } else if friend.status == FRIEND_STATUS.REQUEST_SEND {
            cell.blockButton.isHidden = true
            cell.acceptButton.isHidden = true
            cell.unfriendButton.isHidden = true
            cell.unblockButton.isHidden = true
        } else if friend.status == FRIEND_STATUS.UNBLOCK {
            cell.blockButton.isHidden = true
            cell.acceptButton.isHidden = true
            cell.unfriendButton.isHidden = true
            cell.cancelButton.isHidden = true
        } else {
            cell.acceptButton.isHidden = true
            cell.cancelButton.isHidden = true
            cell.unblockButton.isHidden = true
        }
        return cell
    }
}
