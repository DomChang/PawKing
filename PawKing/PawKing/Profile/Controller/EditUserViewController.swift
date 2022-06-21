//
//  EditUserViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/20.
//

import UIKit

class EditUserViewController: UIViewController {
    
    private let userManager = UserManager.shared
    
    private var userId: String
    
    private var userName: String
    
    private let userNameTextfield = UITextField()
    
    private let descriptionTextView = UITextView()
    
    private let confirmButton = UIButton()
    
    init(userId: String, userName: String) {
        
        self.userId = userId
        
        self.userName = userName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        style()
        layout()
    }
    
    func setup() {
        
        navigationItem.title = "修改資料"
        
        userNameTextfield.text = userName
        
        descriptionTextView.delegate = self
        
        userNameTextfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        
        confirmButtonDisable()
    }
    
    func style() {

        view.backgroundColor = .systemBackground
        
        userNameTextfield.layer.borderColor = UIColor.G1?.cgColor
        userNameTextfield.layer.borderWidth = 1
        
        descriptionTextView.layer.borderColor = UIColor.G1?.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .O1
    }
    
    func layout() {
        
        view.addSubview(userNameTextfield)
        view.addSubview(descriptionTextView)
        view.addSubview(confirmButton)
        
        userNameTextfield.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 height: 30,
                                 padding: UIEdgeInsets(top: 50, left: 20, bottom: 0, right: 20))
        
        descriptionTextView.anchor(top: userNameTextfield.bottomAnchor,
                                   leading: userNameTextfield.leadingAnchor,
                                   trailing: userNameTextfield.trailingAnchor,
                                   height: 100,
                                   padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        confirmButton.anchor(top: descriptionTextView.bottomAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          height: 50,
                          padding: UIEdgeInsets(top: 20, left: 30, bottom: 0, right: 30))
    }
    
    @objc func didTapConfirm() {
        
        guard let userName = userNameTextfield.text,
                let userDescription = descriptionTextView.text else { return }
        
        confirmButtonDisable()
        
        userManager.updateUserInfo(userId: userId,
                                   userName: userName,
                                   userDescription: userDescription) { [weak self] result in
            switch result {
                
            case .success:
                
                print("更新使用者資料成功")
                
                self?.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func confirmButtonEnable() {
        
        confirmButton.backgroundColor = .O1
        confirmButton.isEnabled = true
    }
    
    func confirmButtonDisable() {
        
        confirmButton.backgroundColor = .G1
        confirmButton.isEnabled = false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        guard textField == userNameTextfield else { return }

        if textField.hasText {

            userName = textField.text ?? ""

            confirmButtonEnable()

        } else {
            
            confirmButtonDisable()
        }
    }
}

extension EditUserViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == descriptionTextView {
            
            confirmButtonEnable()
        }
    }
}
