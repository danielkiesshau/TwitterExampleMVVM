//
//  Constants.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import Firebase

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let USERS_REF = DB_REF.child("users")
let TWEET_REF = DB_REF.child("tweets")
let USER_TWEETS_REF = DB_REF.child("user-tweets")
let USER_FOLLOWERS_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")
let TWEET_REPLIES_REF = DB_REF.child("tweet-replies")
