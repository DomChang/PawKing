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
    
    private let tableView = UITableView()
    
    init(pets: [Pet]) {
        self.pets = pets
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
        
        navigationItem.title = "Who do you want to walk with?"
        
        tableView.register(ChoosePetTableViewCell.self,
                           forCellReuseIdentifier: ChoosePetTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func style() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .Orange1
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.backgroundColor = .white
        
        tableView.separatorStyle = .none
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
