//
//  ProfileHeaderViewModel.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 04/10/20.
//

import Foundation
import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}


struct ProfileHeaderViewModel {
    private let user: User
    
    let userNameText: String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: 0, text: "following")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: 2, text: "followers")
    }
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return "Follow"
    }
    
    
    init (user: User) {
        self.user = user
        self.userNameText = "@\(user.username)"
    }
    
    private func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
        ])
        
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray,
        ]))
        
        return attributedTitle
    }
}
