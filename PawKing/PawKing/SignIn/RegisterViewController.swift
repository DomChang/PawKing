//
//  RegisterViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/1.
//

import UIKit
import FirebaseAuth

protocol RegisterViewDelegate {
    
    func didFinishRegister(uid: String)
}

class RegisterViewController: UIViewController {

    var delegate: RegisterViewDelegate?
    
    let userManager = UserManager.shared
    
    let signUpTitleLabel = UILabel()
    
    let emailTextField = InputTextField()
    
    let passwordTextField = InputTextField()
    
    let comfirmPasswordTextField = InputTextField()
    
    let signUpButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        signUpTitleLabel.text = "Sign Up"
        signUpTitleLabel.textColor = .BattleGrey
        signUpTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        emailTextField.placeholder = "Email"
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = "Password"
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        
        comfirmPasswordTextField.placeholder = "Comfirm password"
        comfirmPasswordTextField.autocapitalizationType = .none
        comfirmPasswordTextField.isSecureTextEntry = true
        
        signUpButton.backgroundColor = .Orange1
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signUpButton.layer.cornerRadius = 4
    }
    
    func layout() {

        let registerVStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, comfirmPasswordTextField, signUpButton])
        
        view.addSubview(signUpTitleLabel)
        view.addSubview(registerVStack)
        
        registerVStack.axis = .vertical
        registerVStack.distribution = .fillEqually
        registerVStack.spacing = 20
        
        signUpTitleLabel.anchor(top: view.topAnchor,
                                leading: view.leadingAnchor,
                                trailing: view.trailingAnchor,
                                padding: UIEdgeInsets(top: 300, left: 20, bottom: 0, right: 20))
        
        registerVStack.anchor(top: signUpTitleLabel.bottomAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          height: 240,
                          padding: UIEdgeInsets(top: 24, left: 20, bottom: 0, right: 20))
    }
    
    @objc func didTapSignUp() {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let comfirmPassword = comfirmPasswordTextField.text
        else {
            return
        }
        
        guard password == comfirmPassword else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            if let error = error {

                print(error.localizedDescription)

            } else {
                
                guard let uid = authResult?.user.uid else { return }
                
                self?.userManager.checkUserExist(uid: uid, completion: { isExit in
                    
                    if isExit {
                        
                        print("This account already exist")
                        
                        return
                        
                    } else {
                        
                        self?.dismiss(animated: true, completion: {
                            
                            self?.delegate?.didFinishRegister(uid: uid)
                        })
                    }
                })
            }
        }
    }
}
