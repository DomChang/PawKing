//
//  VideoView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/29.
//

import UIKit
import AuthenticationServices

class SignInView: UIView {
    
    private let logoImageView = UIImageView()
    
    let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    private let signInTitleLabel = UILabel()
    
    let emailTextField = InputTextField()
    
    let passwordTextField = InputTextField()
    
    let signInButton = UIButton()
    
    private let registerHintLabel = UILabel()
    
    let registerButton = UIButton()
    
    private let speratorLeftLine = UIView()
    
    private let orLabel = UILabel()
    
    private let speratorRightLine = UIView()
    
    private let policyLabel = UILabel()
    
    let privacyButton = UIButton()
    
    let eulaButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func style() {
        
        backgroundColor = .clear
        
        logoImageView.image = UIImage.asset(.pawking_logo)
        logoImageView.contentMode = .scaleAspectFill
        
        signInTitleLabel.text = "Sign In"
        signInTitleLabel.textColor = .white
        signInTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        emailTextField.autocapitalizationType = .none
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.backgroundColor = .black.withAlphaComponent(0.2)
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.LightGray ?? .white]
        )
        
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.backgroundColor = .black.withAlphaComponent(0.2)
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.LightGray ?? .white]
        )
        
        signInButton.backgroundColor = .CoralOrange?.withAlphaComponent(0.8)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signInButton.layer.cornerRadius = 4
        
        registerHintLabel.text = "Don't haven an account?"
        registerHintLabel.textColor = .white
        registerHintLabel.textAlignment = .right
        registerHintLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        registerButton.setTitle("Sign up", for: .normal)
        registerButton.setTitleColor(.CoralOrange, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        speratorLeftLine.backgroundColor = .white
        speratorRightLine.backgroundColor = .white
        
        orLabel.text = "OR"
        orLabel.textColor = .white
        orLabel.textAlignment = .center
        orLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        appleButton.layer.cornerRadius = 12
        
        policyLabel.text = "By signing in, you agree to our privacy policy and EULA as below."
        policyLabel.textColor = .white
        policyLabel.textAlignment = .center
        policyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        policyLabel.numberOfLines = 0
        
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(.CoralOrange, for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        eulaButton.setTitle("EULA", for: .normal)
        eulaButton.setTitleColor(.CoralOrange, for: .normal)
        eulaButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    private func layout() {
        
        let signVStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        
        let registerHStack = UIStackView(arrangedSubviews: [registerHintLabel, registerButton])
        
        let policyHStack = UIStackView(arrangedSubviews: [privacyButton, eulaButton])
        
        addSubview(logoImageView)
        addSubview(signInTitleLabel)
        addSubview(signVStack)
        addSubview(registerHStack)
        addSubview(speratorLeftLine)
        addSubview(speratorRightLine)
        addSubview(orLabel)
        addSubview(appleButton)
        addSubview(policyLabel)
        addSubview(policyHStack)
        
        signVStack.axis = .vertical
        signVStack.distribution = .fillEqually
        signVStack.spacing = 20
        
        registerHStack.axis = .horizontal
        registerHStack.distribution = .fill
        registerHStack.spacing = 10
        
        policyHStack.axis = .horizontal
        policyHStack.distribution = .fillEqually
        policyHStack.spacing = 0
        
        registerButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        logoImageView.anchor(top: topAnchor,
                             centerX: centerXAnchor,
                             width: 100,
                             height: 100,
                             padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        
        signInTitleLabel.anchor(leading: leadingAnchor,
                                bottom: signVStack.topAnchor,
                                trailing: trailingAnchor,
                                padding: UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20))
        
        signVStack.anchor(leading: leadingAnchor,
                          bottom: registerHStack.topAnchor,
                          trailing: trailingAnchor,
                          height: 160,
                          padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        
        registerHStack.anchor(leading: signVStack.leadingAnchor,
                              bottom: speratorLeftLine.topAnchor,
                              trailing: signVStack.trailingAnchor,
                              padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        
        speratorLeftLine.anchor(leading: registerHStack.leadingAnchor,
                                bottom: appleButton.topAnchor,
                                trailing: orLabel.leadingAnchor,
                                height: 0.5,
                                padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 10))
        
        orLabel.anchor(centerY: speratorLeftLine.centerYAnchor,
                       centerX: centerXAnchor)
        
        speratorRightLine.anchor(leading: orLabel.trailingAnchor,
                                 trailing: registerHStack.trailingAnchor,
                                 centerY: speratorLeftLine.centerYAnchor,
                                 height: 0.5,
                                 padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
        
        appleButton.anchor(leading: signInButton.leadingAnchor,
                           bottom: bottomAnchor,
                           trailing: signInButton.trailingAnchor,
                           height: 45,
                           padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        
        policyLabel.anchor(top: appleButton.bottomAnchor,
                           leading: appleButton.leadingAnchor,
                           trailing: appleButton.trailingAnchor,
                           padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        policyHStack.anchor(top: policyLabel.bottomAnchor,
                            leading: policyLabel.leadingAnchor,
                            trailing: policyLabel.trailingAnchor,
                            height: 10,
                            padding: UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20))
    }
}
