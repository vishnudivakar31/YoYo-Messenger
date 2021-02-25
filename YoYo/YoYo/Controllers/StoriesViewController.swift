//
//  StoriesViewController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/25/21.
//

import UIKit

class StoriesViewController: UIViewController {

    @IBOutlet weak var myStoryStackView: UIStackView!
    @IBOutlet weak var myStoryImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        myStoryImageView.layer.borderWidth = 2.0
        myStoryImageView.layer.masksToBounds = false
        myStoryImageView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        myStoryImageView.layer.cornerRadius = myStoryImageView.layer.bounds.height / 2
        myStoryImageView.clipsToBounds = true
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x:0, y: self.myStoryStackView.frame.size.height - 1, width: self.myStoryStackView.frame.size.width, height:1)
        bottomBorder.backgroundColor = UIColor.darkGray.cgColor
        myStoryStackView.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func showMyStoriesTapped(_ sender: Any) {
    }
    
    @IBAction func addStoriesTapped(_ sender: Any) {
    }
    
}
