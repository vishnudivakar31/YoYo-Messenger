//
//  AuthenticationService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/8/21.
//

import Foundation
import Firebase
import CommonCrypto

public protocol UserLoginDelegate {
    func signInToUserAccountFailure(msg: String)
    func signInToUserAccountSuccess(user: User, isVerified: Bool)
    func resendEmailVerificationSuccess()
    func resendEmailVerificationFailed(msg: String)
}

public protocol UserAccountCreationDelegate {
    func createUserAccountFailure(msg: String)
    func createUserAccountSuccess(user: User)
}

public protocol PasswordResetDelegate {
    func passwordResetSuccess()
    func passwordResetFailed(msg: String)
}

public protocol UserChangeDelegate {
    func userChangeDetected(status: Bool)
}

class AuthenticationService {
    var userAccountCreationDelegate: UserAccountCreationDelegate?
    var userLoginDelegate: UserLoginDelegate?
    var passwordResetDelegate: PasswordResetDelegate?
    var userChangeDelegate: UserChangeDelegate?
    
    public func createUserAccount(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                self.userAccountCreationDelegate?.createUserAccountFailure(msg: error?.localizedDescription ?? "")
                return
            }
            if error == nil {
                user.sendEmailVerification { (verificationError) in
                    if verificationError != nil {
                        self.userAccountCreationDelegate?.createUserAccountFailure(msg: verificationError?.localizedDescription ?? "")
                    } else {
                        self.userAccountCreationDelegate?.createUserAccountSuccess(user: user)
                    }
                }
            }
        }
    }
    
    public func signInToUserAccount(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                self.userLoginDelegate?.signInToUserAccountFailure(msg: error?.localizedDescription ?? "")
                return
            }
            if error == nil {
                self.userLoginDelegate?.signInToUserAccountSuccess(user: user, isVerified: user.isEmailVerified)
            }
        }
    }
    
    public func reSendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil {
                self.userLoginDelegate?.resendEmailVerificationFailed(msg: error?.localizedDescription ?? "")
            } else {
                self.userLoginDelegate?.resendEmailVerificationSuccess()
            }
        }
    }
    
    public func forgotPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                self.passwordResetDelegate?.passwordResetFailed(msg: error?.localizedDescription ?? "")
            } else {
                self.passwordResetDelegate?.passwordResetSuccess()
            }
        }
    }
    
    public func getUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    public func registerForUserChanges() -> AuthStateDidChangeListenerHandle {
        let listener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if auth.currentUser != user {
                self.userChangeDelegate?.userChangeDetected(status: true)
            } else {
                self.userChangeDelegate?.userChangeDetected(status: false)
            }
        }
        return listener
    }
    
}
