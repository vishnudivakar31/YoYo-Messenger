//
//  HomeTabController.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/14/21.
//

import UIKit
import FirebaseAuth

class HomeTabController: UITabBarController {
    
    private let authenticationService = AuthenticationService()
    private var listener: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.layer.borderWidth = 1
        self.tabBar.layer.borderColor = UIColor.gray.cgColor
        self.tabBar.clipsToBounds = true
        authenticationService.userChangeDelegate = self
        listener = authenticationService.registerForUserChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let listener = listener {
            authenticationService.unregisterUserChanges(listener)
        }
    }
}

// MARK:- UserChange Delegate Methods
extension HomeTabController: UserChangeDelegate {
    func userChangeDetected(status: Bool) {
        if status {
            performSegue(withIdentifier: "GoBackToLandingPage", sender: nil)
        }
    }
    
    
}
