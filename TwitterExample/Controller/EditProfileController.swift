//
//  EditProfileController.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 12/10/20.
//

import UIKit


private let reuseIdentifier = "EditProfileOption"

protocol EditProfileControllerDelegate: class {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
}

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    private var user: User
    private let imagePicker = UIImagePickerController()
    private lazy var headerView = EditProfileHeader(user: user)
    private var selectedImage: UIImage? {
        didSet {
            headerView.profileImageView.image = selectedImage
        }
    }
    weak var delegate: EditProfileControllerDelegate?
    
    private var userInfoChanged = false
    private var imageChanged: Bool {
        return self.selectedImage != nil
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationBar()
        configureImagePicker()
    }
    
    
    // MARK: - Selectors
    
    @objc
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func handleDone() {
        view.endEditing(true)
        guard imageChanged || userInfoChanged else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
        updateUserData()
    }
    
    
    // MARK: - API
    func updateUserData() {
        if imageChanged && !userInfoChanged {
            updateProfileImage()
        }
        
        if userInfoChanged && !imageChanged {
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInfoChanged && imageChanged {
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.delegate?.controller(self, wantsToUpdate: self.user)
                self.updateProfileImage()
            }
        }
        
       
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        UserService.shared.updateProfileImage(image: image) { (profileImageUrl) in
            self.user.profileImageUrl = profileImageUrl
            self.delegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
    // MARK: - Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        
    }
}


// MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}


// MARK: - UITableViewDelegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 150 : 48
    }
}

// MARK: - UITableViewDataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        let option = EditProfileOptions(rawValue: indexPath.row)
        cell.delegate = self
        cell.user =  user
        cell.option = option!
        return cell
    }
    
}


// MARK: - PickerDelegate
extension EditProfileController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        selectedImage = image
        dismiss(animated: (true), completion: nil)
    }
}

// MARK: - EditProfileCellDelegate
extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        
        case .fullname:
            guard let value = cell.infoTextField.text else { return }
            user.fullname = value
        case .username:
            guard let value = cell.infoTextField.text else { return }
            user.username = value
        case .bio:
            user.bio = cell.bioTextView.text
        }
      
    }
    
    
    
    
}
