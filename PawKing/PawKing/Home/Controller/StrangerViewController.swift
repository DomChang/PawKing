//
//  StrangerViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/19.
//

import UIKit
import FirebaseAuth

class StrangerViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var strangerPets: [Pet] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        style()
        layout()
    }
    
    private func setup() {
        
        collectionView.register(
            StrangerCardViewCell.self,
            forCellWithReuseIdentifier: StrangerCardViewCell.identifier)
        
        collectionView.register(
            NoStrangerCell.self,
            forCellWithReuseIdentifier: NoStrangerCell.identifier)
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
    }
    
    private func style() {
        
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func layout() {
        
        view.addSubview(collectionView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        collectionView.fillSuperview()
    }
}

extension StrangerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard Auth.auth().currentUser != nil else {
            
            NotificationCenter.default.post(name: .showSignInView, object: .none)
            return
        }
        
        guard strangerPets.count != 0 else { return }

                let userPhotoWallVC = UserPhotoWallViewController(otherUserId: strangerPets[indexPath.item].ownerId)

                navigationController?.pushViewController(userPhotoWallVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        strangerPets.count == 0 ? 1 : strangerPets.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if strangerPets.count == 0 {
        
            guard let noStrangerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NoStrangerCell.identifier,
                for: indexPath) as? NoStrangerCell else {
                
                fatalError("Can not dequeue NoStrangerCell")
            }
            
            return noStrangerCell
            
        } else {
            
            guard let strangerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StrangerCardViewCell.identifier,
                for: indexPath) as? StrangerCardViewCell else {
                
                fatalError("Can not dequeue StrangerCardViewCell")
            }
            
            strangerCell.configuerCell(with: strangerPets[indexPath.item])
            
            return strangerCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let frameSize = collectionView.frame.size
            return frameSize.width * 0.1
        }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frameSize = collectionView.frame.size
        return CGSize(width: frameSize.width * 0.7, height: frameSize.height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let frameSize = collectionView.frame.size
        return UIEdgeInsets(top: 0, left: frameSize.width * 0.15, bottom: 0, right: frameSize.width * 0.15)
    }
}
