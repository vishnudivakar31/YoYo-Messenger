//
//  HomeTabController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit

class HomeTabController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.gray.cgColor
        self.tabBar.clipsToBounds = true
    }
}
