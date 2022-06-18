//
//  BaseConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

class BaseConfigViewController: UIViewController {
    
    let tableView = UITableView()
    
    let bottomLineView = UIView()
    
    let confirmButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }
    
    func style() {
        
        bottomLineView.backgroundColor = .O1
    
        confirmButton.backgroundColor = .O1
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(bottomLineView)
        view.addSubview(confirmButton)
        
        tableView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        
        bottomLineView.anchor(top: tableView.bottomAnchor,
                              centerX: view.centerXAnchor,
                              width: view.frame.width,
                              height: 1)
        
        confirmButton.anchor(top: bottomLineView.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             height: 30,
                             padding: UIEdgeInsets(top: 20, left: 32, bottom: 0, right: 32))
    }
    
    @objc func didTapConfirm() {
        
    }
}
