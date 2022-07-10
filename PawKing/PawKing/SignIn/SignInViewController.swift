//
//  SignInViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/29.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Lottie
import AVFoundation

protocol SignInViewDelegate {
    
    func showNewUserConfigure()
    
    func signInExistUser()
}

class SignInViewController: UIViewController {
    
    var delegate: SignInViewDelegate?
    
    private let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    private let userManager = UserManager.shared
    
    private let lottie = LottieWrapper.shared
    
    private let logoImageView = UIImageView()
    
    private let signInTitleLabel = UILabel()
    
    private let emailTextField = InputTextField()
    
    private let passwordTextField = InputTextField()
    
    private let signInButton = UIButton()
    
    private let registerHintLabel = UILabel()
    
    private let registerButton = UIButton()
    
    private let speratorLeftLine = UIView()
    
    private let orLabel = UILabel()
    
    private let speratorRightLine = UIView()
    
    fileprivate var currentNonce: String?
    
    private let videoView = UIView()
    
    private var videoPlayer: AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
        style()
        layout()
        playVideo()
        
        setupAppleButton()
    }
    
    deinit {
        
        videoPlayer = nil
    }
    
    func setup() {
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
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
        
        signInButton.backgroundColor = .Orange1?.withAlphaComponent(0.8)
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signInButton.layer.cornerRadius = 4
        
        registerHintLabel.text = "Don't haven an account?"
        registerHintLabel.textColor = .white
        registerHintLabel.textAlignment = .right
        registerHintLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        registerButton.setTitle("Sign up", for: .normal)
        registerButton.setTitleColor(.Orange1, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        speratorLeftLine.backgroundColor = .white
        speratorRightLine.backgroundColor = .white
        
        orLabel.text = "OR"
        orLabel.textColor = .white
        orLabel.textAlignment = .center
        orLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    func layout() {

        let signVStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        
        let registerHStack = UIStackView(arrangedSubviews: [registerHintLabel, registerButton])
        
        view.addSubview(videoView)
        view.addSubview(logoImageView)
        view.addSubview(signInTitleLabel)
        view.addSubview(signVStack)
        view.addSubview(registerHStack)
        view.addSubview(speratorLeftLine)
        view.addSubview(speratorRightLine)
        view.addSubview(orLabel)
        view.addSubview(appleButton)
        
        signVStack.axis = .vertical
        signVStack.distribution = .fillEqually
        signVStack.spacing = 20
        
        registerHStack.axis = .horizontal
        registerHStack.distribution = .fill
        registerHStack.spacing = 10
        
        videoView.fillSuperview()
        
        registerButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//
//        backView.anchor(leading: view.leadingAnchor,
//                        bottom: view.bottomAnchor,
//                        trailing: view.trailingAnchor,
//                        height: 400,
//                        padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        logoImageView.anchor(top: view.topAnchor,
                             centerX: view.centerXAnchor,
                             width: 100,
                             height: 100,
                             padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0))
        
        signInTitleLabel.anchor(leading: view.leadingAnchor,
                                bottom: signVStack.topAnchor,
                                trailing: view.trailingAnchor,
                                padding: UIEdgeInsets(top: 0, left: 20, bottom: 24, right: 20))
        
        signVStack.anchor(leading: view.leadingAnchor,
                          bottom: registerHStack.topAnchor,
                          trailing: view.trailingAnchor,
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
                       centerX: view.centerXAnchor)
        
        speratorRightLine.anchor(leading: orLabel.trailingAnchor,
                                 trailing: registerHStack.trailingAnchor,
                                 centerY: speratorLeftLine.centerYAnchor,
                                 height: 0.5,
                                padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20))
        
    }
    
    func playVideo() {
        
        guard let path = Bundle.main.path(forResource: "signIn", ofType: "mp4") else { return }
       
        let player = AVQueuePlayer()
        let item = AVPlayerItem(url: URL(fileURLWithPath: path))
        videoPlayer = AVPlayerLooper(player: player, templateItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoView.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    @objc func didTapSignIn() {
        
        signInButtonDisable()
        
        lottie.startLoading()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
            
            signInButtonEnable()
            lottie.stopLoading()
            lottie.showError(nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                
                self?.signInButtonEnable()
                self?.lottie.showError(error)
                self?.lottie.stopLoading()
                
            } else {
                
                guard let uid = authResult?.user.uid else { return }
                
                self?.userManager.checkUserExist(uid: uid, completion: { isExit in
                    
                    if isExit {
                        
                        self?.signInButtonEnable()
                        
                        self?.delegate?.signInExistUser()
                        
                        self?.lottie.stopLoading()

                        self?.dismiss(animated: true)
                        
                    } else {
                        
                        self?.signInButtonEnable()
                        
                        self?.lottie.stopLoading()
                        
                        self?.lottie.showError(nil)
                        print("Please Sign Up First!")
                    }
                })
            }
        }
    }
    
    @objc func didTapRegister() {
        
        let registerVC = RegisterViewController()
        
        registerVC.delegate = self
        
        present(registerVC, animated: true)
    }
    
    func setupAppleButton() {
        appleButton.layer.cornerRadius = 12
        appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        
        appleButton.anchor(bottom: view.bottomAnchor,
                           centerX: view.centerXAnchor,
                           width: 235,
                           height: 45,
                           padding: UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0))
    }
    
    @objc func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }
        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }
          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }
      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    func signInButtonEnable() {
        
        signInButton.isEnabled = true
        signInButton.backgroundColor = .Orange1
    }
    
    func signInButtonDisable() {
        
        signInButton.isEnabled = false
        signInButton.backgroundColor = .Gray1
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
      
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        
      guard let nonce = currentNonce else {
          
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
          
        print("Unable to fetch identity token")
          
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          
        return
      }
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
          
        if let error = error {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
          print(error.localizedDescription)
          return
        }
        
          guard let uid = authResult?.user.uid else { return }
          
          self.userManager.checkUserExist(uid: uid) { [weak self] isExist in

              if isExist {

                  self?.delegate?.signInExistUser()

                  self?.dismiss(animated: true)

              } else {

                  guard let userName = appleIDCredential.fullName?.givenName else { return }

                  let user = User(id: uid,
                                  name: userName,
                                  petsId: [],
                                  currentPetId: "",
                                  userImage: "",
                                  description: "",
                                  friendPetsId: [],
                                  friends: [],
                                  recieveRequestsId: [],
                                  sendRequestsId: [],
                                  blockUsersId: [])

                  self?.userManager.setupUser(user: user) { [weak self] result in

                      switch result {

                      case .success:

                          self?.dismiss(animated: true)

                          self?.delegate?.showNewUserConfigure()

                          UserManager.shared.currentUser = user

                      case .failure(let error):

                          print(error)
                      }
                  }
              }
          }
      }
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
    
//    func checkUserExist(uid: String, userName: String?) {
//
//        self.userManager.checkUserExist(uid: uid) { [weak self] isExist in
//
//            if isExist {
//
//                self?.delegate?.signInExistUser()
//
//                self?.dismiss(animated: true)
//
//            } else {
//
//                let user = User(id: uid,
//                                name: userName ?? "",
//                                petsId: [],
//                                currentPetId: "",
//                                userImage: "",
//                                description: "",
//                                friendPetsId: [],
//                                friends: [],
//                                recieveRequestsId: [],
//                                sendRequestsId: [])
//
//                self?.userManager.setupUser(user: user) { [weak self] result in
//
//                    switch result {
//
//                    case .success:
//
//                        self?.dismiss(animated: true)
//
//                        self?.delegate?.showNewUserConfigure()
//
//                        UserManager.shared.currentUser = user
//
//                    case .failure(let error):
//
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
}

extension SignInViewController: RegisterViewDelegate {
    
    func didFinishRegister(uid: String) {
        
        lottie.startLoading()
        
        self.dismiss(animated: true) { [weak self] in
            
            let user = User(id: uid,
                            name: "",
                            petsId: [],
                            currentPetId: "",
                            userImage: "",
                            description: "",
                            friendPetsId: [],
                            friends: [],
                            recieveRequestsId: [],
                            sendRequestsId: [],
                            blockUsersId: [])

            self?.userManager.setupUser(user: user) {  result in

                switch result {

                case .success:
                    
                    self?.lottie.stopLoading()

                    self?.dismiss(animated: true)

                    self?.delegate?.showNewUserConfigure()

                    UserManager.shared.currentUser = user

                case .failure(let error):
                    
                    self?.lottie.stopLoading()
                    self?.lottie.showError(error)
                }
            }
        }
    }
}
