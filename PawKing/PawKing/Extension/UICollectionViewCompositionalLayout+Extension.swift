//
//  UICollectionViewCompositionalLayout+Extension.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/24.
//

import UIKit.UICollectionViewCompositionalLayout

extension UICollectionViewCompositionalLayout {
    
    static func userPhotoWallCompositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = UserPhotoWallSections.allCases[sectionIndex]
            
            switch section {
                
            case .userInfo:
                
                let infoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                          heightDimension: .fractionalHeight(1))
                let infoItem = NSCollectionLayoutItem(layoutSize: infoItemSize)
                
                let infoGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(150))
                let infoGroup = NSCollectionLayoutGroup.vertical(layoutSize: infoGroupSize, subitems: [infoItem])
                
                let infoSection = NSCollectionLayoutSection(group: infoGroup)
                
                let infoBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(ProfileInfoReusableView.self)")

                infoSection.decorationItems = [infoBackView]
                
                return infoSection
                
            case .choosePet:
                
                let petItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .fractionalHeight(1))
                let petItem = NSCollectionLayoutItem(layoutSize: petItemSize)
                
                let petGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(80),
                                                          heightDimension: .absolute(80))
                
                let petGroup = NSCollectionLayoutGroup.horizontal(layoutSize: petGroupSize, subitems: [petItem])
                
                let petSection = NSCollectionLayoutSection(group: petGroup)
                
                petSection.orthogonalScrollingBehavior = .continuous
                petSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                
                petSection.interGroupSpacing = 10
                
                let petItemBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(OtherUserPetReusableView.self)")

                petSection.decorationItems = [petItemBackView]
                
                return petSection
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 2, trailing: 1)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                postSection.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 2, bottom: 0, trailing: 2)
                
                return postSection
            }
        }
    }
    
    static func profileViewCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = ProfileSections.allCases[sectionIndex]
            
            switch section {
                
            case .userInfo:
                
                let infoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                          heightDimension: .fractionalHeight(1))
                let infoItem = NSCollectionLayoutItem(layoutSize: infoItemSize)
                
                let infoGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(150))
                let infoGroup = NSCollectionLayoutGroup.vertical(layoutSize: infoGroupSize, subitems: [infoItem])
                
                let infoSection = NSCollectionLayoutSection(group: infoGroup)
                
                let infoBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(ProfileInfoReusableView.self)")

                infoSection.decorationItems = [infoBackView]
                
                return infoSection
                
            case .choosePet:
                
                let petItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                         heightDimension: .fractionalHeight(1))
                let petItem = NSCollectionLayoutItem(layoutSize: petItemSize)
                
                let petGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(80),
                                                          heightDimension: .absolute(80))
                
                let petGroup = NSCollectionLayoutGroup.horizontal(layoutSize: petGroupSize, subitems: [petItem])
                
                let petSection = NSCollectionLayoutSection(group: petGroup)
                
                petSection.orthogonalScrollingBehavior = .continuous
                petSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                
                petSection.interGroupSpacing = 10
                
                let petItemBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(PetItemBackReusableView.self)")

                petSection.decorationItems = [petItemBackView]
                
                return petSection
                
            case .chooseContent:
                
                let chooseItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                            heightDimension: .fractionalHeight(1))
                let chooseItem = NSCollectionLayoutItem(layoutSize: chooseItemSize)
                
                let chooseGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                             heightDimension: .absolute(40))
                let chooseGroup = NSCollectionLayoutGroup.horizontal(layoutSize: chooseGroupSize,
                                                                     subitems: [chooseItem])
                
                let chooseSection = NSCollectionLayoutSection(group: chooseGroup)
                
                chooseSection.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                let chooseBackView = NSCollectionLayoutDecorationItem.background(
                    elementKind: "\(ContentButtonReusableView.self)")

                chooseSection.decorationItems = [chooseBackView]
                
                return chooseSection
                
            case .postsPhoto:
                    
                let postItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3),
                                                          heightDimension: .fractionalHeight(1))
                let postItem = NSCollectionLayoutItem(layoutSize: postItemSize)
                
                postItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 2, trailing: 1)
                
                let postGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .fractionalWidth(1 / 3))
                let postGroup = NSCollectionLayoutGroup.horizontal(layoutSize: postGroupSize, subitems: [postItem])
                
                let postSection = NSCollectionLayoutSection(group: postGroup)
                
                postSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
                
                return postSection

            }
        }
    }
    
    static func exploreViewCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { _, _ in
        
            let contentInset: CGFloat = 1
            
            // Full
            let fullItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalWidth(1))
            let fullItem = NSCollectionLayoutItem(layoutSize: fullItemSize)

            fullItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                             leading: contentInset,
                                                             bottom: contentInset,
                                                             trailing: contentInset)

            let fullGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalWidth(1))

            let fullGroup = NSCollectionLayoutGroup.vertical(layoutSize: fullGroupSize,
                                                                 subitem: fullItem, count: 1)

            // Main with pair
            let mainItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3),
                                                      heightDimension: .fractionalHeight(1))
            let mainItem = NSCollectionLayoutItem(layoutSize: mainItemSize)

            mainItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                             leading: contentInset,
                                                             bottom: contentInset,
                                                             trailing: contentInset)

            let pairItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1/2))
            let pairItem = NSCollectionLayoutItem(layoutSize: pairItemSize)

            pairItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                             leading: contentInset,
                                                             bottom: contentInset,
                                                             trailing: contentInset)

            let trailingGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                       heightDimension: .fractionalHeight(1))
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: trailingGroupSize,
                                                                 subitem: pairItem,
                                                                 count: 2)

            let mainWithPairGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                               heightDimension: .fractionalWidth(2/3))

            let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize,
                                                                     subitems: [mainItem, trailingGroup])

            // Triplet
            let tripletItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                    heightDimension: .fractionalHeight(1))
            let tripletItem = NSCollectionLayoutItem(layoutSize: tripletItemSize)

            tripletItem.contentInsets = NSDirectionalEdgeInsets(top: contentInset,
                                                                leading: contentInset,
                                                                bottom: contentInset,
                                                                trailing: contentInset)

            let tripletGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                               heightDimension: .fractionalWidth(1/3))

            let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: tripletGroupSize,
                                                                  subitems: [tripletItem, tripletItem, tripletItem])

            // Reversed main with pair
            let mainWithRevGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize,
                                                                    subitems: [trailingGroup, mainItem])

            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                               heightDimension: .fractionalWidth(8/3))

            let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: nestedGroupSize,
                                                                 subitems: [fullGroup,
                                                                            mainWithPairGroup,
                                                                            tripletGroup,
                                                                            mainWithRevGroup])

            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            return section
        }
    }
}
