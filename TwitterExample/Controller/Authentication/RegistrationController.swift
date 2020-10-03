//
//  LoginController.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 02/10/20.
//

import UIKit

class RegistrationController: UIViewController  {
    
    // MARK: - Properties
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        return Utilities.inputContainerView(withImage: #imageLiteral(resourceName: "ic_mail_outline_white_2x-1"), textField: emailTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return Utilities.inputContainerView(withImage: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    }()
    
    private let emailTextField:  UITextField = {
        return Utilities.textField(withPlaceHolder: "Email")
    }()
    
    private let passwordTextField:  UITextField = {
        let tf = Utilities.textField(withPlaceHolder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var fullnameContainerView: UIView = {
        return Utilities.inputContainerView(withImage: #imageLiteral(resourceName: "ic_mail_outline_white_2x-1"), textField: fullnameTextField)
    }()
    
    private lazy var usernameContainerView: UIView = {
        return Utilities.inputContainerView(withImage: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: usernameTextField)
    }()
    
    private let fullnameTextField:  UITextField = {
        return Utilities.textField(withPlaceHolder: "Full Name")
    }()
    
    private let usernameTextField:  UITextField = {
        let tf = Utilities.textField(withPlaceHolder: "User name")
        return tf
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sing up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside )
        return button
    }()
    
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities.attributedButton("Already have an account?", "  Log In!")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAddProfilePhoto() {
        print("handle add profile photo")
    }
    
    @objc func handleRegistration() {
        print("handleRegistration")
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 40, paddingRight: 40)
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        plusPhotoButton.setDimensions(width: 128, height: 128)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullnameContainerView, usernameContainerView, signUpButton])
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32,paddingLeft: 32, paddingRight: 32 )
    }
}
