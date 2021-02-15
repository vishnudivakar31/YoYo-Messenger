//
//  AddFriendViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/15/21.
//

import UIKit
import SDWebImage

class AddFriendViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var profiles: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SearchResult", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchResult")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.tintColor = .black
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .black
        }
    }
}

// MARK:- TableView Delegate Methods
extension AddFriendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profile = profiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResult", for: indexPath) as! SearchResult
        cell.nameLabel.text = profile.name
        cell.emailLabel.text = profile.userEmail
        cell.profileImage.sd_setImage(with: URL(string: profile.profilePictureURL), completed: nil)
        return cell
    }
}

// MARK:- Searchbar Delegate Methods
extension AddFriendViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar.text
        print(searchText ?? "")
    }
}
