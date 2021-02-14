//
//  RequestViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit

class RequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        
    }
    @IBAction func addRequestTapped(_ sender: Any) {
    }
}

extension RequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
