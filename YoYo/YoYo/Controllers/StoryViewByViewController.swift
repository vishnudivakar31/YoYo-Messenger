//
//  StoryViewByViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/1/21.
//

import UIKit
import SDWebImage

class StoryViewByViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewedByUIDS: [String]?
    
    private var users: [UserModel] = []
    private let storyService = StoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
    
    private func fetchUserModels() {
        if let viewedByUIDS = viewedByUIDS {
            storyService.fetchUserModels(uids: viewedByUIDS) { (userModels, error) in
                if let error = error {
                    self.presentAlert(title: "Viewed By", msg: error.localizedDescription)
                } else if let userModels = userModels {
                    self.users = userModels
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func presentAlert(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK:- Table delegate methods
extension StoryViewByViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryTableViewCell", for: indexPath) as! StoryTableViewCell
        cell.friendName.text = user.name
        cell.friendImageView.sd_setImage(with: URL(string: user.profilePictureURL), completed: nil)
        return cell
    }
}
