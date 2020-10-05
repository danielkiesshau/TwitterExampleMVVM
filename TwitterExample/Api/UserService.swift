//
//  UserService.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import Firebase

struct UserService {
    static let shared = UserService()
    
    private init() { }
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        
        USERS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)

            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        var users = [User]()
        USERS_REF.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            if userUid != snapshot.key {
                let user = User(uid: snapshot.key, dictionary: dictionary)
                users.append(user)
                completion(users)
            }
            
        }
    }
}
