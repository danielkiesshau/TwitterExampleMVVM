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
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(Error?, DatabaseReference, String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = [
            "uid": uid,
            "timestamp": Int(NSDate().timeIntervalSince1970),
            "likes": 0,
            "retweets": 0,
            "caption": caption
        ] as [String: Any]
        
        switch type {
        case .tweet:
            TWEET_REF.childByAutoId().updateChildValues(values) { (error, ref) in
                // update user-tweets structure after tweet's been uploaded
                guard let tweetID = ref.key else { return }
                USER_TWEETS_REF.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: { (error, ref) in
                    completion(error,ref, tweetID)
                })
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            TWEET_REPLIES_REF.child(tweet.tweetID).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyKey = ref.key else  { return }
                USER_REPLIES_REF.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: { (error, ref) in
                    completion(error,ref, replyKey)
                })
            }
        }
    }
    
    func fetchTweets(completion: @escaping([Tweet]) -> Void)  {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            USER_TWEETS_REF.child(followingUid).observe(.childAdded) { (snapshot) in
                let tweetID = snapshot.key
                self.fetchTweet(withTweetID: tweetID) { (tweet) in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        USER_TWEETS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { (tweet) in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        TWEET_REF.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return  }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweetID = snapshot.key
                
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        USER_TWEETS_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID, completion: {tweet in
                tweets.append(tweet)
                
                completion(tweets)
            })
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        TWEET_REPLIES_REF.child(tweet.tweetID).observe(.childAdded) { (snapshot) in
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
    
    func fetchReplies(forUser user:User, completion: @escaping(([Tweet]) -> Void)) {
        var replies = [Tweet]()
        
        USER_REPLIES_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            TWEET_REPLIES_REF.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return  }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                UserService.shared.fetchUser(uid: uid) { (user) in
                    let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        USER_LIKES_REF.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { (likedTweet) in
                var tweet = likedTweet
                tweet.didLike = true
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        
        TWEET_REF.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            // Unlike tweet
            USER_LIKES_REF.child(uid).child(tweet.tweetID).removeValue() {err, ref in
                TWEET_LIKES_REF.child(tweet.tweetID).child(uid).removeValue(completionBlock: completion)
            }
        } else {
            // Like tweet
            USER_LIKES_REF.child(uid).updateChildValues([tweet.tweetID: 1]) { (err, ref) in
                TWEET_LIKES_REF.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
}
