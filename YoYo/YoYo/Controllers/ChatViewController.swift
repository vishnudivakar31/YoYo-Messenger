//
//  ChatViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 3/9/21.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let messagingService = MessagingService()
    private var chatModels: [ChatModel] = []
    private var listeners: [ListenerRegistration] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        messagingService.chatDelegate = self
        messagingService.fetchChatModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listeners = messagingService.registerForChatModelChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for listener in listeners {
            listener.remove()
        }
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatTableViewCell")
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
            if let chatModel = sender as? ChatModel {
                viewController.userModel = chatModel.userModel
            }
        }
    }
    
}

// MARK:- Table Delegate Methods
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatModel = chatModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        cell.profileName.text = chatModel.userModel.name
        if chatModel.unSeenMessages > 0 {
            cell.numberOfUnreadMessages.isHidden = false
            cell.numberOfUnreadMessages.text = "\(chatModel.unSeenMessages)"
        } else {
            cell.numberOfUnreadMessages.isHidden = true
        }
        cell.profileImageView.sd_setImage(with: URL(string: chatModel.userModel.profilePictureURL), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatModel = chatModels[indexPath.row]
        performSegue(withIdentifier: "GoToMessagesFromChat", sender: chatModel)
    }
    
}

// MARK:- Chat Serivce Delegate
extension ChatViewController: ChatServiceDelegate {
    func chatModelChanged(success: Bool, error: Error?) {
        if error != nil {
            self.presentAlert(title: "Messages", msg: error?.localizedDescription ?? "")
        } else if success {
            self.messagingService.fetchChatModels()
        }
    }
    
    func fetchChatModels(chatModels: [ChatModel], error: Error?) {
        if error != nil {
            self.presentAlert(title: "Messages", msg: error?.localizedDescription ?? "")
        } else {
            self.chatModels = chatModels
            self.tableView.reloadData()
        }
    }
    
    
}
