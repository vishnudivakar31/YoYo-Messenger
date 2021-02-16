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
    
    private let searchService = SearchService()
    private var profiles: [UserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SearchResult", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SearchResult")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = 140
        searchBar.delegate = self
        searchService.delegate = self
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
        cell.uid = profile.userID
        return cell
    }
}

// MARK:- Searchbar Delegate Methods
extension AddFriendViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let searchText = searchBar.text ?? ""
        if searchText.count > 0 {
            searchService.searchUserProfiles(searchString: searchText)
        }
    }
}

// MARK:- SearchService Delegate Methods
extension AddFriendViewController: SearchDelegate {
    func searchCompleted(profiles: [UserModel]?, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "")
        } else {
            if let profiles = profiles {
                self.profiles = profiles
                self.tableView.reloadData()
            }
        }
    }
}
