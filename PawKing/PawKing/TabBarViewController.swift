//
//  TabBarViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private enum Tab {

    case map

    case explore

    case publish

    case chat
    
    case profile

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .map: controller = UINavigationController(rootViewController: MapViewController())

        case .explore: controller = UINavigationController(rootViewController: ExploreViewController())
            
        case .publish: controller =
            UINavigationController(rootViewController:
                                    PublishViewController(image: UIImage.asset(.Image_Placeholder)!))
            
        case .chat: controller = UINavigationController(rootViewController: ChatRoomViewController())

        case .profile: controller = UINavigationController(rootViewController: ProfileViewController())
            
        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .map:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_24px_Map_Normal),
                selectedImage: UIImage.asset(.Icons_24px_Map_Selected)
            )

        case .explore:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_24px_Explore_Normal),
                selectedImage: UIImage.asset(.Icons_24px_Explore_Selected)
            )

        case .publish:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_24px_Publish),
                selectedImage: UIImage.asset(.Icons_24px_Publish)
            )
            
        case .chat:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_24px_Chat_Normal),
                selectedImage: UIImage.asset(.Icons_24px_Chat_Selected)
            )

        case .profile:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_24px_Profile_Normal),
                selectedImage: UIImage.asset(.Icons_24px_Profile_Selected)
            )
        }
    }
}

class TabBarViewController: UITabBarController {
    
//    private let userId = "7jkh07vJvBjgd9F5qkrB"

    private let tabs: [Tab] = [.map, .explore, .publish, .chat, .profile]
    
    private let userManager = UserManager.shared
    
    private let photoHelper = PKPhotoHelper()
    
    private let alertController = UIAlertController(title: "No Pet",
                                                    message: "Cannot post with no pet, please add pet first!",
                                                    preferredStyle: .alert)
    
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSignInView),
                                               name: .showSignInView,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetTab),
                                               name: .resetTab,
                                               object: nil)
        
        view.backgroundColor = .white
        
        tabBar.isHidden = true
        
        tabBar.tintColor = .Orange1
        
        delegate = self
        
        tabBar.isHidden = false
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            
            self.selectedIndex = 4
        })
        
        alertController.addAction(cancelAction)
        
        if let userId = Auth.auth().currentUser?.uid {

            listenUser(userId: userId)

        } else {
  
            UserManager.shared.currentUser = userManager.guestUser
        }
        
        configureUserToTab()

        let tabBarAppearance =  UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.shadowColor = .clear
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.standardAppearance = tabBarAppearance
        
        let navBarAppearance =  UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .BattleGrey
        navBarAppearance.shadowColor = .clear
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showSignInView()
    }
    
    @objc func showSignInView() {
        
        if Auth.auth().currentUser == nil {
            
            let signInVC = SignInViewController()
            
            signInVC.delegate = self
            
            present(signInVC, animated: true)
        }
    }
    
    @objc func listenUser(userId: String) {
        
        if listener != nil {
            
            listener?.remove()
        }
        
        listener = userManager.listenUserInfo(userId: userId) { result in
            
            switch result {
                
            case .success(let user):
                
                print("===22222")
                
                UserManager.shared.currentUser = user
                
            case .failure(let error):
                
                print(error)
            }
        }
    }

    func configureUserToTab() {
        
        tabBar.isHidden = false
        
        viewControllers = tabs.map({ $0.controller() })
        
        photoHelper.completionHandler = { [weak self] image in
            
            let navPublishVC = UINavigationController(
                rootViewController: PublishViewController(image: image))
            
            navPublishVC.modalPresentationStyle = .fullScreen
            navPublishVC.navigationBar.tintColor = .white

            self?.present(navPublishVC, animated: true)
        }
    }
    
    @objc func resetTab() {
        
        viewControllers = tabs.map({ $0.controller() })
    }
}

extension TabBarViewController: SignInViewDelegate {
    
    func signInExistUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listenUser(userId: uid)
    }
    
    func showNewUserConfigure() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listenUser(userId: uid)
        
        let userConfigVC = UserConfigViewController(uid: uid)
        
        let navUserConfigVC = UINavigationController(rootViewController: userConfigVC)
        
        navUserConfigVC.modalPresentationStyle = .fullScreen

        present(navUserConfigVC, animated: true)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        guard Auth.auth().currentUser?.uid != nil else {
            
            let index = viewControllers?.firstIndex(of: viewController)
            
            if index == 2 || index == 3 || index == 4 {
                
                let signInVC = SignInViewController()
                
                signInVC.delegate = self
                
                present(signInVC, animated: true)
                
                return false
            }
            return true
        }
        
        let user = UserManager.shared.currentUser
        
        if viewControllers?.firstIndex(of: viewController) == 2 {
            
            if user?.petsId.count == 0 {
                
                present(alertController, animated: true)
                
                return false
            }
            
            photoHelper.presentActionSheet(from: self)
            
            return false
        }
        return true
    }
}
