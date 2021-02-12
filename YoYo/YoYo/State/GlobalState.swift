//
//  GlobalState.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/12/21.
//

import Foundation

class GlobalState {
    static let shared = GlobalState()
    var userModel: UserModel?
    
    private init() {}
    
    func getUserModel() -> UserModel? {
        return userModel
    }
}
