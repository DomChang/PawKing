//
//  PublishViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/14.
//

import UIKit

final class PublishViewController: UIViewController {
    
    var photoImage = UIImage()
    
    let photoImageView = UIImageView()
    
    let captionTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    init(image: UIImage) {
        
        self.photoImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        photoImageView.image = photoImage
    }
    
    func style() {
        
        view.backgroundColor = .white
        photoImageView.contentMode = .scaleAspectFit
        
        captionTextView.layer.borderWidth = 1
        captionTextView.layer.borderColor = UIColor.G1?.cgColor
    }
    
    func layout() {
        
        view.addSubview(photoImageView)
        view.addSubview(captionTextView)
        
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              centerX: view.centerXAnchor,
                              width: 330,
                              height: 330,
                              padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        
        captionTextView.anchor(top: photoImageView.bottomAnchor,
                               centerX: view.centerXAnchor,
                               width: 330,
                               height: 160,
                               padding: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
    }
}
