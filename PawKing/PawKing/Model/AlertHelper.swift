//
//  AlertHelper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/27.
//

import UIKit

class AlertHelper {
    
    typealias Action = () -> Void
    
    func showAlert(title: String?,
                   message: String?,
                   actionName: String,
                   actionStyle: UIAlertAction.Style,
                   action: @escaping Action,
                   by viewController: UIViewController) {
        
        let alerContorller = UIAlertController(title: title,
                                               message: message,
                                               preferredStyle: .alert)
        DispatchQueue.main.async {
            alerContorller.view.tintColor = .BattleGrey
        }
        
        alerContorller.addAction(UIAlertAction(title: actionName,
                                               style: actionStyle,
                                               handler: { (_) in action() }))
        
        alerContorller.addAction(.cancel)
        
        viewController.present(alerContorller, animated: true)
    }
    
    func showActionSheet(title: String?,
                         message: String?,
                         actionName: String,
                         actionStyle: UIAlertAction.Style,
                         action: @escaping Action,
                         by viewController: UIViewController) {
        
        let alerContorller = UIAlertController(title: title,
                                               message: message,
                                               preferredStyle: .actionSheet)
        DispatchQueue.main.async {
            alerContorller.view.tintColor = .BattleGrey
        }
        
        alerContorller.addAction(.cancel)
        
        alerContorller.addAction(UIAlertAction(title: actionName,
                                               style: actionStyle,
                                               handler: { (_) in action() }))
        
        viewController.present(alerContorller, animated: true)
    }
}

extension UIAlertAction {
    static var cancel: UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
}
