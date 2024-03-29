//
//  User.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    var username: String
    var fullname: String
    var profileImageUrl: URL?
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid}
    var isFollowed = false
    var stats: UserRelationStats?
    var bio: String
    
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        if let profileImageUrlString = dictionary["profileImage"] as? String {
            guard let url =  URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
        
        
    }
    
}


struct UserRelationStats {
    var following: Int
    var followers: Int
}
