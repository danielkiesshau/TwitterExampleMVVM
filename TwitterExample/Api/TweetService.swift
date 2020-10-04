//
//  TweetService.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import Firebase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [
            "uid": uid,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0,
            "caption": caption
        ] as [String: Any]
        let ref = TWEET_REF.childByAutoId()
        ref.updateChildValues(values) { (error, ref) in
            // update user-tweets structure after tweet's been uploaded
            guard let tweetID = ref.key else { return }
            USER_TWEETS_REF.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void)  {
        var tweets = [Tweet]()
        
        TWEET_REF.observe(DataEventType.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return  }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweetID = snapshot.key
                 
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                
                completion(tweets)
            }
            
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        USER_TWEETS_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            TWEET_REF.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return  }
                
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                
                completion(tweets)
            }
        }
    }
}
