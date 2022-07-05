//
//  TabBarViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit
import FirebaseAuth

private enum Tab {

    case map

    case explore

    case publish

    case chat
    
    case profile

    func controller(user: User) -> UIViewController {

        var controller: UIViewController

        switch self {

        case .map: controller = UINavigationController(rootViewController: MapViewController(user: user))

        case .explore: controller = UINavigationController(rootViewController: ExploreViewController())
            
        case .publish: controller =
            UINavigationController(rootViewController:
                                    PublishViewController(image: UIImage.asset(.Image_Placeholder)!))
            
        case .chat: controller = UINavigationController(rootViewController: ChatRoomViewController())

        case .profile: controller = UINavigationController(rootViewController: ProfileViewController(user: user))
            
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSignInView),
                                               name: .showSignInView,
                                               object: nil)
        
        view.backgroundColor = .white
        
        tabBar.isHidden = true
        
        tabBar.tintColor = .Orange1
        
        delegate = self
        
        tabBar.isHidden = false
        
        if let userId = Auth.auth().currentUser?.uid {
            
//            let userId = "6jRPSQJEw7NWuyZl2BCs"
            getUser(userId: userId)
            
        } else {

            let user = User(id: "Guest",
                            name: "Guest",
                            petsId: [],
                            currentPetId: "",
                            userImage: "",
                            description: "",
                            friendPetsId: [],
                            friends: [],
                            recieveRequestsId: [],
                            sendRequestsId: [],
                            blockUsersId: [])

            configureUserToTab(user: user)
            
            UserManager.shared.currentUser = user
        }

        let tabBarAppearance =  UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.shadowColor = .clear
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.standardAppearance = tabBarAppearance
        
        let navBarAppearance =  UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .DarkBlue
        navBarAppearance.shadowColor = .clear
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.Orange1 ?? .white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        showSignInView()
    }
    
    @objc func showSignInView() {
        
        if Auth.auth().currentUser == nil {
            
            let signInVC = SignInViewController()
            
            signInVC.delegate = self
            
            present(signInVC, animated: true)
        }
    }
    
    @objc func getUser(userId: String) {
        
        userManager.fetchUserInfo(userId: userId) { [weak self] result in
            
            switch result {
                
            case .success(let user):
                
                UserManager.shared.currentUser = user
                
                self?.configureUserToTab(user: user)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
//    @objc func didSetCurrentUser() {
//        
//        guard let user = userManager.currentUser else { return }
//        
//        configureUserToTab(user: user)
//    }
    
    func configureUserToTab(user: User) {
        
        tabBar.isHidden = false
        
        viewControllers = tabs.map({ $0.controller(user: user) })
        
        photoHelper.completionHandler = { [weak self] image in
            
            let navPublishVC = UINavigationController(
                rootViewController: PublishViewController(image: image))
            
            navPublishVC.modalPresentationStyle = .fullScreen

            self?.present(navPublishVC, animated: true)
        }
    }
}

extension TabBarViewController: SignInViewDelegate {
    
    func signInExistUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        getUser(userId: uid)
    }
    
    func showNewUserConfigure() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userConfigVC = UserConfigViewController(uid: uid)
        
        let navUserConfigVC = UINavigationController(rootViewController: userConfigVC)

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
        
        if let navigaton = viewController as? UINavigationController,
           navigaton.viewControllers.contains(where: { return $0 is PublishViewController }) {
            
            photoHelper.presentActionSheet(from: self)
            
            return false
        }
        return true
    }
}
