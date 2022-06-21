//
//  ViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

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
            
        case .publish: controller = UINavigationController(rootViewController: PublishViewController(image:
                                                                                                        UIImage.asset(.Image_Placeholder)!))
        case .chat: controller = UINavigationController(rootViewController: ChatViewController())

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

    private let tabs: [Tab] = [.map, .explore, .publish, .chat, .profile]
    
    let photoHelper = PKPhotoHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoHelper.completionHandler = { [weak self] image in
            
            let navPublishVC = UINavigationController(rootViewController: PublishViewController(image: image))
            
            navPublishVC.modalPresentationStyle = .fullScreen

            self?.present(navPublishVC, animated: true)
        }
        
        delegate = self

        viewControllers = tabs.map({ $0.controller() })
        
        let tabBarAppearance =  UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.standardAppearance = tabBarAppearance
        
        let navBarAppearance =  UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        
        if let navigaton = viewController as? UINavigationController,
           navigaton.viewControllers.contains(where: { return $0 is PublishViewController }) {
            
            photoHelper.presentActionSheet(from: self)
            
            return false
        }
        return true
    }
}