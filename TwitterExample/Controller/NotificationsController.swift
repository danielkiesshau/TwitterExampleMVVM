//
//  FeedController.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 02/10/20.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    // MARK: - Properties
    var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        tableView.backgroundColor = .white
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - API
    
    
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { (notifications) in
            guard !notifications.isEmpty else {
                self.refreshControl?.endRefreshing()
                return
            }
            self.notifications = notifications
            self.checkIFUserIsFollowed(notifications: notifications)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func checkIFUserIsFollowed(notifications: [Notification]) {
        
        notifications.forEach { (notification) in
            guard case .follow = notification.type else { return }
            
            let user = notification.user
            
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
                if let index = self.notifications.firstIndex(where: {$0.user.uid == notification.user.uid}) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
            
        }
    }
    
    // MARK: - Selectors
    
    @objc
    func handleRefresh() {
        fetchNotifications()
    }
}


extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else { return }
        TweetService.shared.fetchTweet(withTweetID: tweetID, completion: { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        })
    }
}


// MARK: - TableViewDataSource
extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.contentView.isUserInteractionEnabled = true
        cell.delegate = self
        return cell
    }
    
}

// MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                cell.notification.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                cell.notification.user.isFollowed = true
            }
        }
    }
    
    func didTapProfileImageTapped(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
