//
//  ChoosePetViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

protocol ChoosePetViewDelegate {
    
    func didChoosePet(with selectedPet: Pet)
}

class ChoosePetViewController: UIViewController {
    
    var delegate: ChoosePetViewDelegate?
    
    private var pets: [Pet]
    
    private var isPost: Bool
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(pets: [Pet], isPost: Bool) {
        self.pets = pets
        self.isPost = isPost
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
        
        if isPost {
            
            navigationItem.title = "Who do you want to post with?"
        } else {
         
            navigationItem.title = "Who do you want to walk with?"
        }
        
        tableView.register(ChoosePetTableViewCell.self,
                           forCellReuseIdentifier: ChoosePetTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func style() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.BattleGrey ?? .white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.backgroundColor = .LightGray
    }
    
    func layout() {
        
        view.addSubview(tableView)
        
        tableView.fillSuperview()
    }
    
}

extension ChoosePetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoosePetTableViewCell.identifier, for: indexPath)
                as? ChoosePetTableViewCell
        else {
            fatalError("Cannot dequeue ChoosePetTableViewCell")
        }
        
        cell.configureCell(pet: pets[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.didChoosePet(with: pets[indexPath.row])
        
        self.dismiss(animated: true)
    }
}
