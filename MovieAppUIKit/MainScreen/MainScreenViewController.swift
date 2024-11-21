//
//  MainScreenViewController.swift
//  MovieAppUIKit
//
//  Created by Niño Christian Amahan on 11/18/24.
//

import UIKit

class MainScreenViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subheadingLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }

    func prepareViews() {
        headingLabel.text = NSLocalizedString("login_header", comment: "")
        headingLabel.textColor = .appPrimary
        subheadingLabel.text = NSLocalizedString("login_subheader", comment: "")
        subheadingLabel.textColor = .appPrimary.withAlphaComponent(0.7)


        loginButton.setTitle(NSLocalizedString("login_button", comment: ""), for: .normal)
        loginButton.tintColor = .appPrimary
        loginButton.addTarget(self, action: #selector(loginButtonPress), for: .touchUpInside)

        signupButton.setTitle(NSLocalizedString("signup_button", comment: ""), for: .normal)
        signupButton.setTitleColor(.appPrimary, for: .normal)
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.appPrimary.cgColor
        signupButton.layer.cornerRadius = 10
        signupButton.addTarget(self, action: #selector(signupButtonPress), for: .touchUpInside)
        
    }
    
    @objc
    func loginButtonPress() {
    }
    
    @objc
    func signupButtonPress() {
        
    }

}
