//
//  HomeTabController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit

class HomeTabController: UITabBarController {
    
    private let authenticationService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.gray.cgColor
        self.tabBar.clipsToBounds = true
        authenticationService.userChangeDelegate = self
    }
}

// MARK:- User Changes Delegate Methods
extension HomeTabController: UserChangeDelegate {
    func userChangeDetected(status: Bool) {
        if status {
            performSegue(withIdentifier: "GoToLandingPage", sender: nil)
        }
    }
}
