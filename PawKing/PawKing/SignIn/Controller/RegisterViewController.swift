//
//  RegisterViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/1.
//

import UIKit
import FirebaseAuth
import AVFoundation

protocol RegisterViewDelegate: AnyObject {
    
    func didFinishRegister(uid: String)
}

class RegisterViewController: UIViewController {

    weak var delegate: RegisterViewDelegate?
    
    private let welcomeImageView = UIImageView()
    
    private let signUpTitleLabel = UILabel()
    
    private let emailTextField = InputTextField()
    
    private let passwordTextField = InputTextField()
    
    private let comfirmPasswordTextField = InputTextField()
    
    private let signUpButton = UIButton()
    
    private let policyLabel = UILabel()
    
    private let privacyButton = UIButton()
    
    private let eulaButton = UIButton()
    
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
        
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        
        eulaButton.addTarget(self, action: #selector(didTapEULA), for: .touchUpInside)
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
        
        signUpButton.backgroundColor = .CoralOrange?.withAlphaComponent(0.8)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signUpButton.layer.cornerRadius = 4
        
        policyLabel.text = "By signing up, you agree to our privacy policy and EULA as below."
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
    
    func layout() {
        
        view.addSubview(videoView)
        view.addSubview(welcomeImageView)

        let registerVStack = UIStackView(arrangedSubviews: [emailTextField,
                                                            passwordTextField,
                                                            comfirmPasswordTextField,
                                                            signUpButton])
        
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
        
        let policyHStack = UIStackView(arrangedSubviews: [privacyButton, eulaButton])
        
        policyHStack.axis = .horizontal
        policyHStack.distribution = .fillEqually
        policyHStack.spacing = 0
        
        view.addSubview(policyLabel)
        view.addSubview(policyHStack)
        
        policyLabel.anchor(top: registerVStack.bottomAnchor,
                           leading: registerVStack.leadingAnchor,
                           trailing: registerVStack.trailingAnchor,
                           padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        
        policyHStack.anchor(top: policyLabel.bottomAnchor,
                            leading: policyLabel.leadingAnchor,
                            trailing: policyLabel.trailingAnchor,
                            height: 10,
                            padding: UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20))
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
        
        signUpButtonDisable()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let comfirmPassword = comfirmPasswordTextField.text
        else {
            signUpButtonEnable()
            
            return
        }
        
        guard password == comfirmPassword else {
            
            signUpButtonEnable()
            LottieWrapper.shared.showError(errorMessage: "Wrong password")
            return
        }
        
        LottieWrapper.shared.startLoading()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            if let error = error {

                print(error.localizedDescription)
                self?.signUpButtonEnable()
                LottieWrapper.shared.showError(errorMessage: "Wrong acount or password")
                LottieWrapper.shared.stopLoading()

            } else {
                
                guard let uid = authResult?.user.uid else {
                    self?.signUpButtonEnable()
                    LottieWrapper.shared.stopLoading()
                    return
                }
                
                UserManager.shared.checkUserExist(uid: uid, completion: { isExit in
                    
                    if isExit {

                        LottieWrapper.shared.showError(errorMessage: "This account already exist")
                        self?.signUpButtonEnable()
                        LottieWrapper.shared.stopLoading()
                        return
                        
                    } else {
                        
                        self?.signUpButtonEnable()
                        LottieWrapper.shared.stopLoading()
                        self?.dismiss(animated: true, completion: {
                            
                            self?.delegate?.didFinishRegister(uid: uid)
                        })
                    }
                })
            }
        }
    }
    
    @objc private func didTapPrivacy() {
        
        let privacyVC = PrivacyViewController()
        present(privacyVC, animated: true)
    }
    
    @objc private func didTapEULA() {
        
        let eulaVC = EULAViewController()
        present(eulaVC, animated: true)
    }
    
    private func signUpButtonEnable() {
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = .CoralOrange
    }
    
    private func signUpButtonDisable() {
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .MainGray
    }
}
