//
//  BaseConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

class BaseConfigViewController: UIViewController {
    
    let tableView = UITableView()
    
    let photoHelper = PKPhotoHelper()
    
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
        
        navigationController?.navigationBar.isHidden = false
        
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func style() {
        
        bottomLineView.backgroundColor = .Orange1
    
        confirmButton.backgroundColor = .Orange1
    }
    
    func layout() {
        
        view.addSubview(tableView)
        view.addSubview(bottomLineView)
        view.addSubview(confirmButton)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor,
                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        
        bottomLineView.anchor(top: tableView.bottomAnchor,
                              centerX: view.centerXAnchor,
                              width: view.frame.width,
                              height: 1)
        
        confirmButton.anchor(top: bottomLineView.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             height: 50,
                             padding: UIEdgeInsets(top: 20, left: 32, bottom: 0, right: 32))
    }
    
    func confirmButtonEnable() {
        
        confirmButton.backgroundColor = .Orange1
        confirmButton.isEnabled = true
    }
    
    func confirmButtonDisable() {
        
        confirmButton.backgroundColor = .Gray1
        confirmButton.isEnabled = false
    }
}

extension BaseConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        0
    }
}
