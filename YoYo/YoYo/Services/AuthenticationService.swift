//
//  AuthenticationService.swift
//  YoYo
//
//  Created by Vishnu Divakar on 2/8/21.
//

import Foundation
import Firebase
import CommonCrypto

public protocol AuthenticationDelegate {
    func createUserAccountFailure(msg: String)
    func createUserAccountSuccess(user: User)
    func signInToUserAccountFailure(msg: String)
    func signInToUserAccountSuccess(user: User)
}

class AuthenticationService {
    var delegate: AuthenticationDelegate?
    
    public func createUserAccount(email: String, password: String) {
        let hashedPassword = hashString(withString: password) ?? ""
        if hashedPassword.count > 0 {
            Auth.auth().createUser(withEmail: email, password: hashedPassword) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    self.delegate?.createUserAccountFailure(msg: error?.localizedDescription ?? "")
                    return
                }
                if error == nil {
                    user.sendEmailVerification { (verificationError) in
                        if verificationError != nil {
                            self.delegate?.createUserAccountFailure(msg: verificationError?.localizedDescription ?? "")
                        } else {
                            self.delegate?.createUserAccountSuccess(user: user)
                        }
                    }
                }
            }
        }
    }
    
    public func signInToUserAccount(email: String, password: String) {
        let hashedPassword = hashString(withString: password) ?? ""
        if hashedPassword.count > 0 {
            Auth.auth().signIn(withEmail: email, password: hashedPassword) { (authResult, error) in
                guard let user = authResult?.user, error == nil else {
                    self.delegate?.signInToUserAccountFailure(msg: error?.localizedDescription ?? "")
                    return
                }
                if error == nil {
                    self.delegate?.signInToUserAccountSuccess(user: user)
                }
            }
        }
    }
    
    private func hashString(withString: String) -> String? {
        if let validStringData = withString.data(using: String.Encoding.utf8) {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            let _ = validStringData.withUnsafeBytes {
                CC_SHA256($0.baseAddress, UInt32(validStringData.count), &digest)
            }
            var sha256String = ""
            for byte in digest {
                sha256String += String(format: "%02", UInt8(byte))
            }
            return sha256String
        }
        return nil
    }
    
}
