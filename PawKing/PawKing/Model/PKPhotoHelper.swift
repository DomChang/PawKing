//
//  PKPhotoHelper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import UIKit

class PKPhotoHelper: NSObject {
    
    // MARK: - Properties

    var completionHandler: ((UIImage) -> Void)?

        // MARK: - Helper Methods

    func presentActionSheet(from viewController: UIViewController) {
        // 1
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.view.tintColor = .BattleGrey

        // 2
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Camera",
                                                   style: .default,
                                                   handler: { [weak self] _ in
                self?.presentImagePickerController(with: .camera, from: viewController)
            })

            alertController.addAction(capturePhotoAction)
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Library",
                                             style: .default,
                                             handler: { [weak self] _ in
                self?.presentImagePickerController(with: .photoLibrary, from: viewController)
            })

            alertController.addAction(uploadAction)
        }

        // 6
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)

        // 7
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerController.SourceType,
                                      from viewController: UIViewController) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = sourceType
        
        imagePickerController.allowsEditing = true
        
        imagePickerController.delegate = self

        viewController.present(imagePickerController, animated: true)
    }
}

extension PKPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage  else {
            
            picker.dismiss(animated: true)
            
            return
        }

        picker.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(selectedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
