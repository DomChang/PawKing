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

protocol SignInViewDelegate {
    
    func showNewUserConfigure()
    
    func signInExistUser()
}

class SignInViewController: UIViewController {
    
    var delegate: SignInViewDelegate?
    
    let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    let userManager = UserManager.shared
    
    let signInTitleLabel = UILabel()
    
    let emailTextField = InputTextField()
    
    let passwordTextField = InputTextField()
    
    let signInButton = UIButton()
    
    let registerHintLabel = UILabel()
    
    let registerButton = UIButton()
    
    let speratorLeftLine = UIView()
    
    let orLabel = UILabel()
    
    let speratorRightLine = UIView()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupAppleButton()
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
        
        signInTitleLabel.text = "Sign In"
        signInTitleLabel.textColor = .DarkBlue
        signInTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        emailTextField.placeholder = "Email"
        emailTextField.autocapitalizationType = .none
        
        passwordTextField.placeholder = "Password"
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        
        signInButton.backgroundColor = .Orange1
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signInButton.layer.cornerRadius = 4
        
        registerHintLabel.text = "Don't haven an account?"
        registerHintLabel.textColor = .darkGray
        registerHintLabel.textAlignment = .right
        registerHintLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        registerButton.setTitle("Sign up", for: .normal)
        registerButton.setTitleColor(.Orange1, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        speratorLeftLine.backgroundColor = .Gray1
        speratorRightLine.backgroundColor = .Gray1
        
        orLabel.text = "OR"
        orLabel.textColor = .Gray1
        orLabel.textAlignment = .center
        orLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    func layout() {

        let signVStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])
        
        let registerHStack = UIStackView(arrangedSubviews: [registerHintLabel, registerButton])
        
        view.addSubview(signInTitleLabel)
        view.addSubview(signVStack)
        view.addSubview(registerHStack)
        view.addSubview(speratorLeftLine)
        view.addSubview(speratorRightLine)
        view.addSubview(orLabel)
        
        signVStack.axis = .vertical
        signVStack.distribution = .fillEqually
        signVStack.spacing = 20
        
        registerHStack.axis = .horizontal
        registerHStack.distribution = .fill
        registerHStack.spacing = 10
        
        
        registerButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//
//        backView.anchor(leading: view.leadingAnchor,
//                        bottom: view.bottomAnchor,
//                        trailing: view.trailingAnchor,
//                        height: 400,
//                        padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
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
    
    @objc func didTapSignIn() {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                
                print(error.localizedDescription)
                
            } else {
                
                guard let uid = authResult?.user.uid else { return }
                
                self?.userManager.checkUserExist(uid: uid, completion: { isExit in
                    
                    if isExit {
                        
                        self?.delegate?.signInExistUser()

                        self?.dismiss(animated: true)
                        
                    } else {
                        
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
        view.addSubview(appleButton)
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