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
    
    fileprivate var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        layout()
        
        setupAppleButton()
    }
    
    func layout() {
        
        
    }
    
    
    func setupAppleButton() {
        view.addSubview(appleButton)
        appleButton.layer.cornerRadius = 12
        appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        appleButton.widthAnchor.constraint(equalToConstant: 235).isActive = true
        appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
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
                                  recieveFriendRequest: [],
                                  sendRequestsId: [])
                  
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
}
