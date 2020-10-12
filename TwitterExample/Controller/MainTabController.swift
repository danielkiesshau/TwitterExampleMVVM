//
//  MainTabController.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 02/10/20.
//

import UIKit
import Firebase


class MainTabController: UITabBarController {
    // MARK: - Properties
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .twitterBlue
        self.tabBar.barTintColor = .white
        self.tabBar.tintColor = .twitterBlue
//        logUserOut()
        authenticateUserAndConfigureUI()
    }

    // MARK: - Selectors
    @objc func actionButtonTapped() {
        guard let user = user else { return }
        let nav = UINavigationController(rootViewController: UploadTweetController(user: user, config:  .tweet))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.addSubview(actionButton)
        let buttonSize = CGFloat(56)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingBottom: 64, paddingRight: 16, width: buttonSize, height: buttonSize)
        actionButton.layer.cornerRadius = CGFloat(buttonSize / 2)
        
    }
    
    func configureViewControllers() {
        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        
        let feed = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedController)
        let explore = templateNavigationController(image: UIImage(named: "search_unselected"), rootViewController: ExploreController())
        let notifications = templateNavigationController(image: UIImage(named: "like_unselected"), rootViewController: NotificationsController())
        let conversations = templateNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsController())
        
        // set the Viewcontrollers for the tabbar
        viewControllers = [feed, explore, notifications, conversations]
        
    }
    
    func templateNavigationController(image: UIImage?, rootViewController: UIViewController) ->
        UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.tabBarItem.badgeColor = .white
        nav.navigationBar.barTintColor = .white
        
        return nav
    }
    
    // MARK: - API
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: User logged out")
        } catch let error {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { (user) in
            self.user = user
        }
    }
}
