//
//  LottieWrapper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import Foundation
import Lottie
import UIKit

enum LottieName: String {
    
    case loading
    
    case error
    
    case like
}

class LottieWrapper {
    
    static let shared = LottieWrapper()
    
    private lazy var blurView = UIView()
    
    private let width = UIScreen.main.bounds.width
    
    private let height = UIScreen.main.bounds.height
    
    private let currentWindow = UIApplication.shared
                                                    .connectedScenes
                                                    .compactMap { $0 as? UIWindowScene }
                                                    .first?
                                                    .windows
                                                    .first
    
    private let loadingView = AnimationView(name: LottieName.loading.rawValue)
    
    private let errorView = AnimationView(name: LottieName.error.rawValue)
    
    private let likingView = AnimationView(name: LottieName.like.rawValue)
    
    private let errorLabel = UILabel()
    
    func startLoading() {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = .BattleGrey?.withAlphaComponent(0.3)
        
        currentWindow?.addSubview(blurView)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)

        loadingView.center = currentWindow?.center ?? CGPoint(x: width / 2, y: height / 2)
        
        loadingView.contentMode = .scaleAspectFill
        
        loadingView.backgroundBehavior = .pauseAndRestore
        
        currentWindow?.addSubview(loadingView)
        
        DispatchQueue.main.async {
            
            self.currentWindow?.isUserInteractionEnabled = false
            
            self.loadingView.play()
        }
        
        loadingView.loopMode = .loop
    }
    
    func stopLoading() {
        
        DispatchQueue.main.async {
            
            self.currentWindow?.isUserInteractionEnabled = true
            
            self.loadingView.removeFromSuperview()

            self.blurView.removeFromSuperview()
            
            self.loadingView.stop()
        }
    }
    
    func showError(error: Error?) {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = .white.withAlphaComponent(0.1)
        
        currentWindow?.addSubview(blurView)
        
        let vStack = UIStackView(arrangedSubviews: [errorView, errorLabel])
        
        errorView.constrainWidth(constant: 150)
        errorView.constrainHeight(constant: 150)
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.backgroundColor = .LightGray?.withAlphaComponent(0.8)
        vStack.spacing = 5
        vStack.layer.cornerRadius = 20
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        vStack.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        if let error = error {
            errorLabel.text = String(describing: error)
        } else {
            errorLabel.text = "Failure"
        }
        
        errorLabel.textColor = .CoralOrange
        errorLabel.numberOfLines = 0
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        errorView.contentMode = .scaleAspectFill
        errorView.backgroundBehavior = .forceFinish
        
        currentWindow?.addSubview(vStack)
        
        vStack.center = currentWindow?.center ?? CGPoint(x: width / 2, y: height / 2)
        
        errorView.play()
        errorView.animationSpeed = 1
        errorView.loopMode = .loop
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {

            vStack.removeFromSuperview()
        }
    }
    
    func showError(errorMessage: String?) {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = .white.withAlphaComponent(0.1)
        
        currentWindow?.addSubview(blurView)
        
        let vStack = UIStackView(arrangedSubviews: [errorView, errorLabel])
        
        errorView.constrainWidth(constant: 150)
        errorView.constrainHeight(constant: 150)
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.backgroundColor = .LightGray?.withAlphaComponent(0.8)
        vStack.spacing = 5
        vStack.layer.cornerRadius = 20
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        vStack.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        if let errorMessage = errorMessage {
            errorLabel.text = errorMessage
        } else {
            errorLabel.text = "Failure"
        }
        
        errorLabel.textColor = .CoralOrange
        errorLabel.numberOfLines = 0
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        errorView.contentMode = .scaleAspectFill
        errorView.backgroundBehavior = .forceFinish
        
        currentWindow?.addSubview(vStack)
        
        vStack.center = currentWindow?.center ?? CGPoint(x: width / 2, y: height / 2)
        
        errorView.play()
        errorView.animationSpeed = 1
        errorView.loopMode = .loop
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {

            vStack.removeFromSuperview()
        }
    }
    
    func showLikeAnimation(addTo view: UIView, cell: PhotoPostCell) {
        
        likingView.contentMode = .scaleAspectFill
        likingView.animationSpeed = 1.25
        likingView.backgroundBehavior = .forceFinish
        likingView.loopMode = .playOnce
        likingView.setRadiusWithShadow()
        
        view.addSubview(likingView)
        
        likingView.anchor(centerY: cell.photoImageView.centerYAnchor,
                          centerX: cell.photoImageView.centerXAnchor,
                          width: 250,
                          height: 250,
                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        DispatchQueue.main.async {
            
            self.likingView.play { _ in
                self.likingView.stop()
                self.likingView.removeFromSuperview()
            }
        }
    }
}
