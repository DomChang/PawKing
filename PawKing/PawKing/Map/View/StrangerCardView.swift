//
//  StrangerCardView.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/17.
//

import UIKit

//class StrangerCardView: UIView {
//
//    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//    
//    var datas: [User] = [] {
//
//        didSet {
//            
//            collectionView.reloadData()
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        initView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//
//        initView()
//    }
//
//    private func initView() {
//
//        setup()
//        style()
//        layout()
//    }
//    
//    func setup() {
//        
//        collectionView.register(
//            StrangerCardViewCell.self,
//            forCellWithReuseIdentifier: StrangerCardViewCell.identifier
//        )
//        
//        collectionView.dataSource = self
//        
//        collectionView.delegate = self
//        
////        collectionView.isHidden = true
//        
//    }
//    
//    func style() {
//        
//        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.scrollDirection = .horizontal
//        }
//        
//        collectionView.backgroundColor = .clear
//    }
//    
//    func layout() {
//        
//        self.addSubview(collectionView)
//        
//        collectionView.anchor(leading: self.leadingAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor, trailing: self.trailingAnchor, height: 130)
//    }
//}
//
//
