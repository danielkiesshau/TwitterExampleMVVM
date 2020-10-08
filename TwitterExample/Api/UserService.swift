//
//  UserService.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

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
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // create following
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1]) { (error, ref) in
            // create follower
            USER_FOLLOWERS_REF.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // remove following
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue() { (error, ref) in
            // remove follower
            USER_FOLLOWERS_REF.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
        USER_FOLLOWING_REF.child(currentUid).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStats) -> Void) {
        USER_FOLLOWING_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let followers = snapshot.children.allObjects.count
            
            USER_FOLLOWERS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                let following = snapshot.children.allObjects.count
                
                let stats = UserRelationStats(following: following, followers: followers)
                
                completion(stats)
                
            }
        }
    }
}
