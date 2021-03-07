//
//  ComposeViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/7/21.
//

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let messagingService = MessagingService()
    private var userModels:[UserModel] = []
    private var searchResultBuffer:[UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagingService.delegate = self
        searchBar.delegate = self
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .black
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MessageViewController {
            let viewController = segue.destination as! MessageViewController
            viewController.userModel = (sender as! UserModel)
        }
    }
    
}

// MARK:- Messaging Service Delegate Methods
extension ComposeViewController: MessageServiceDelegate {
    func getMyFriendsCompleted(friends: [UserModel]?, error: Error?) {
        if let error = error {
            self.userModels = []
            presentAlert(title: "Friends", msg: error.localizedDescription)
        } else if let userModels = friends {
            self.userModels = userModels.sorted(by: { $0.name < $1.name })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userModels[indexPath.row]
        performSegue(withIdentifier: "GoToMessageFromCompose", sender: user)
    }

}

// MARK:- UISearchBar Delegate Methods
extension ComposeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
        if self.searchResultBuffer.count == 0 {
            self.searchResultBuffer = self.userModels
        }
        let searchText = searchBar.text ?? ""
        if searchText.count > 0 {
            self.userModels = self.searchResultBuffer.filter { $0.name.contains(searchText.lowercased()) || $0.userEmail.contains(searchText.lowercased()) }
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            self.resignFirstResponder()
            self.userModels = self.searchResultBuffer
            self.searchResultBuffer = []
            self.tableView.reloadData()
        }
    }
}
