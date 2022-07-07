//
//  RegisterViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/1.
//

import UIKit
import FirebaseAuth
import AVFoundation

protocol RegisterViewDelegate {
    
    func didFinishRegister(uid: String)
}

class RegisterViewController: UIViewController {

    var delegate: RegisterViewDelegate?
    
    let userManager = UserManager.shared
    
    private let welcomeImageView = UIImageView()
    
    let signUpTitleLabel = UILabel()
    
    let emailTextField = InputTextField()
    
    let passwordTextField = InputTextField()
    
    let comfirmPasswordTextField = InputTextField()
    
    let signUpButton = UIButton()
    
    private let videoView = UIView()
    
    private var videoPlayer: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        style()
        layout()
        playVideo()
    }
    
    deinit {
        
        videoPlayer = nil
    }
    
    func setup() {
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        welcomeImageView.image = UIImage.asset(.signUp)
        welcomeImageView.contentMode = .scaleAspectFill
        
        signUpTitleLabel.text = "Sign Up"
        signUpTitleLabel.textColor = .white
        signUpTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
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
        
        comfirmPasswordTextField.placeholder = "Comfirm password"
        comfirmPasswordTextField.autocapitalizationType = .none
        comfirmPasswordTextField.isSecureTextEntry = true
        comfirmPasswordTextField.layer.borderColor = UIColor.white.cgColor
        comfirmPasswordTextField.backgroundColor = .black.withAlphaComponent(0.2)
        comfirmPasswordTextField.textColor = .white
        comfirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Comfirm password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.LightGray ?? .white]
        )
        
        signUpButton.backgroundColor = .Orange1?.withAlphaComponent(0.8)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signUpButton.layer.cornerRadius = 4
    }
    
    func layout() {
        
        view.addSubview(videoView)
        view.addSubview(welcomeImageView)

        let registerVStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, comfirmPasswordTextField, signUpButton])
        
        view.addSubview(signUpTitleLabel)
        view.addSubview(registerVStack)
        
        registerVStack.axis = .vertical
        registerVStack.distribution = .fillEqually
        registerVStack.spacing = 20
        
        videoView.fillSuperview()
        
        welcomeImageView.anchor(bottom: signUpTitleLabel.topAnchor,
                             centerX: view.centerXAnchor,
                             width: 60,
                             height: 60,
                             padding: UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0))
        
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
    
    func playVideo() {
        
        guard let path = Bundle.main.path(forResource: "signUp", ofType: "mp4") else { return }
       
        let player = AVQueuePlayer()
        let item = AVPlayerItem(url: URL(fileURLWithPath: path))
        videoPlayer = AVPlayerLooper(player: player, templateItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(playerLayer)
        
        player.play()
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
