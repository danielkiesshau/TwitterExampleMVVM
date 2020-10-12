//
//  AuthService.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let fullname: String
    let username: String
    let password: String
    let profileImage: UIImage
}
struct AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentias: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        let email = credentias.email
        let password = credentias.password
        let fullname = credentias.fullname
        let username = credentias.username
        let profileImage = credentias.profileImage
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                let values = [
                    "email": email,
                    "username": username,
                    "fullname": fullname,
                    "profileImage": profileImageUrl
                ]
                
                Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                    if let error = error {
                        print("DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    USERS_REF.child(uid).updateChildValues(values, withCompletionBlock: completion )
                    
                    
                    print("DEBUG: Successfully registered user")
                })
            }
        }
    }
}
