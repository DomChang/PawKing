//
//  LottieWrapper.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/6.
//

import Foundation
import Lottie

enum LottieName: String {
    
    case loading
    
    case error
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
    
    private let errorLabel = UILabel()
    
    func startLoading() {
        
        currentWindow?.isUserInteractionEnabled = false
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = .BattleGrey?.withAlphaComponent(0.3)
        
        currentWindow?.addSubview(blurView)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)

        loadingView.center = currentWindow?.center ?? CGPoint(x: width / 2, y: height / 2)
        
        loadingView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(loadingView)
        
        DispatchQueue.main.async {
            self.loadingView.play()
        }
        
        loadingView.loopMode = .loop
    }
    
    func stopLoading() {
        
        currentWindow?.isUserInteractionEnabled = true
        
        DispatchQueue.main.async {
            
            self.loadingView.removeFromSuperview()

            self.blurView.removeFromSuperview()
            
            self.loadingView.stop()
        }
    }
    
    func showError(_ error: Error?) {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = .white.withAlphaComponent(0.1)
        
        currentWindow?.addSubview(blurView)
        
        let vStack = UIStackView(arrangedSubviews: [errorView, errorLabel])
        
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
        
        errorLabel.textColor = .Orange1
        
        errorLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        errorView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(vStack)
        
        vStack.center = currentWindow?.center ?? CGPoint(x: width / 2, y: height / 2)
        
        errorView.play()
        
        errorView.loopMode = .loop
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {

            vStack.removeFromSuperview()
        }
    }
}
