//
//  EditProfileCell.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 12/10/20.
//

import UIKit


protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    // MARK: - Properties
    
    var user: User?
    
    var viewModel: EditProfileViewModel? {
        didSet {
            configure()
        }
    }
    
    var option: EditProfileOptions? {
        didSet {
            guard let option = self.option else { return }
            guard let user = self.user else { return }
            viewModel = EditProfileViewModel(option: option, user: user)
        }
    }
    
    var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return tf
    }()
    
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .twitterBlue
        tv.placeholderLabel.text = "Bio"
        tv.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return tv
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, infoTextField, bioTextView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        
        self.contentView.addSubview(stack)
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc
    func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        bioTextView.placeholderLabel.isHidden = user?.bio.count ?? 0 > 0
        titleLabel.text = viewModel.titleText
        
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
        
    }
}
