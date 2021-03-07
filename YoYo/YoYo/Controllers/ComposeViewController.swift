//
//  ComposeViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let messagingService = MessagingService()
    private var userModels:[UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagingService.delegate = self
        setupTableView()
        messagingService.getMyFriends()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "StoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK:- Messaging Service Delegate Methods
extension ComposeViewController: MessageServiceDelegate {
    func getMyFriendsCompleted(friends: [UserModel]?, error: Error?) {
        if let error = error {
            self.userModels = []
            presentAlert(title: "Friends", msg: error.localizedDescription)
        } else if let userModels = friends {
            self.userModels = userModels
        }
        self.tableView.reloadData()
    }
}

// MARK:- Table View Delegate Methods
extension ComposeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryTableViewCell", for: indexPath) as! StoryTableViewCell
        cell.friendName.text = user.name
        cell.friendImageView.sd_setImage(with: URL(string: user.profilePictureURL), completed: nil)
        return cell
    }
}
