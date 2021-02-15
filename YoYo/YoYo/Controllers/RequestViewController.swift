//
//  RequestViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit

class RequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    private let requestService = RequestServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
}

extension RequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
