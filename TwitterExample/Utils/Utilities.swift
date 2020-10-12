//
//  Utilities.swift
//  TwitterExample
//
//  Created by Daniel Kiesshau on 03/10/20.
//

import UIKit

class Utilities {
    static func inputContainerView(withImage image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let iv = UIImageView()
        view.addSubview(iv)
        iv.image = image
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 8, paddingBottom: 8)
        iv.setDimensions(width: 24, height: 24)
        
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        view.addSubview(dividerView)
        dividerView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        
        return view
    }
    
    static func textField(withPlaceHolder placeholder: String, color: UIColor = .white) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.textColor = color
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: color
        ])
        return tf
    }
    
    static func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            
        attributedTitle.append(NSMutableAttributedString(string: secondPart, attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
        ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }
}
