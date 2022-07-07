//
//  EULAViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/7/7.
//

import UIKit
import WebKit

class EULAViewController: UIViewController {

    private let webView = WKWebView()
    
    private let closeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }
    
    private func setup() {
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        guard let url = URL(
            string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        )
        else {
            return
        }
        
        webView.load(URLRequest(url: url))
        
        closeButton.setImage(UIImage(systemName: "xmark",
                                     withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
                             for: .normal)
    }
    
    private func layout() {
        
        view.addSubview(webView)
        view.addSubview(closeButton)
        
        webView.fillSuperview()
        
        closeButton.anchor(top: view.topAnchor,
                           trailing: view.trailingAnchor,
                           width: 40,
                           height: 40,
                           padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16))
    }
    
    @objc func didTapClose() {
        
        dismiss(animated: true)
    }
}
