//
//  EditProfileViewModel.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 12/10/20.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        
        case .fullname:
            return "Name"
        case .username:
            return "Username"
        case .bio:
            return "Bio"
        }
    }
}

class EditProfileViewModel {
    var shouldHideTextField: Bool {
        return option == .bio
    }
    var shouldHideTextView: Bool {
        return option != .bio
    }
    var optionValue: String {
        switch option {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    var titleText: String {
        return option.description
    }
    
    private var user: User
    
    var option: EditProfileOptions {
        didSet {
           configure()
        }
    }
    
    init(option: EditProfileOptions, user: User) {
        self.option = option
        self.user = user
    }
    
    func configure() {
        
    }
}
