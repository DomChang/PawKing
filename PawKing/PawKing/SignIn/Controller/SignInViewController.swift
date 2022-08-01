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

protocol SignInViewDelegate: AnyObject {
    
    func showNewUserConfigure()
    
    func signInExistUser()
}

class SignInViewController: UIViewController {
    
    weak var delegate: SignInViewDelegate?
    
    fileprivate var currentNonce: String?
    
    private let videoView = UIView()
    
    private let signInView = SignInView()
    
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
        
        signInView.appleButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        
        signInView.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        signInView.registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        signInView.privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        
        signInView.eulaButton.addTarget(self, action: #selector(didTapEULA), for: .touchUpInside)
    }
    
    func style() {
        
        view.backgroundColor = .white
    }
    
    func layout() {
        
        view.addSubview(videoView)
        view.addSubview(signInView)
        
        videoView.fillSuperview()
        signInView.fillSuperview()
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
        
        LottieWrapper.shared.startLoading()
        
        guard let email = signInView.emailTextField.text,
              let password = signInView.passwordTextField.text
        else {
            
            signInButtonEnable()
            LottieWrapper.shared.stopLoading()
            LottieWrapper.shared.showError(error: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            
            if error != nil {
                
                self?.signInButtonEnable()
                LottieWrapper.shared.showError(errorMessage: "Wrong acount or password")
                LottieWrapper.shared.stopLoading()
                
            } else {
                
                guard let uid = authResult?.user.uid else { return }
                
                UserManager.shared.checkUserExist(uid: uid, completion: { isExit in
                    
                    if isExit {
                        
                        self?.signInButtonEnable()
                        
                        self?.delegate?.signInExistUser()
                        
                        LottieWrapper.shared.stopLoading()
                        
                        self?.dismiss(animated: true)
                        
                    } else {
                        
                        self?.signInButtonEnable()
                        
                        LottieWrapper.shared.stopLoading()
                        
                        LottieWrapper.shared.showError(errorMessage: "Please sign up first")
                    }
                })
            }
        }
    }
    
    @objc private func didTapRegister() {
        
        let registerVC = RegisterViewController()
        
        registerVC.delegate = self
        
        present(registerVC, animated: true)
    }
    
    @objc private func didTapPrivacy() {
        
        let privacyVC = PrivacyViewController()
        present(privacyVC, animated: true)
    }
    
    @objc private func didTapEULA() {
        
        let eulaVC = EULAViewController()
        present(eulaVC, animated: true)
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
        
        signInView.signInButton.isEnabled = true
        signInView.signInButton.backgroundColor = .CoralOrange
    }
    
    func signInButtonDisable() {
        
        signInView.signInButton.isEnabled = false
        signInView.signInButton.backgroundColor = .MainGray
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
                    
                    print(error.localizedDescription)
                    return
                }
                
                guard let uid = authResult?.user.uid else { return }
                
                UserManager.shared.checkUserExist(uid: uid) { [weak self] isExist in
                    
                    if isExist {
                        
                        self?.delegate?.signInExistUser()
                        
                        self?.dismiss(animated: true)
                        
                    } else {
                        
                        let userName = appleIDCredential.fullName?.givenName
                        
                        let user = User(id: uid,
                                        name: userName ?? "",
                                        petsId: [],
                                        currentPetId: "",
                                        userImage: "",
                                        description: "",
                                        friendPetsId: [],
                                        friends: [],
                                        recieveRequestsId: [],
                                        sendRequestsId: [],
                                        blockUsersId: [])
                        
                        UserManager.shared.setupUser(user: user) { [weak self] result in
                            
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
        
        print("Sign in with Apple errored: \(error)")
    }
}

extension SignInViewController: RegisterViewDelegate {
    
    func didFinishRegister(uid: String) {
        
        LottieWrapper.shared.startLoading()
        
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
            
            UserManager.shared.setupUser(user: user) {  result in
                
                switch result {
                    
                case .success:
                    
                    LottieWrapper.shared.stopLoading()

                    self?.dismiss(animated: true)

                    self?.delegate?.showNewUserConfigure()

                    UserManager.shared.currentUser = user

                case .failure(let error):
                    
                    LottieWrapper.shared.stopLoading()
                    LottieWrapper.shared.showError(error: error)
                }
            }
        }
    }
}
