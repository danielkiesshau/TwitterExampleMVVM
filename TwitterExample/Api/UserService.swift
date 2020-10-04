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
}
