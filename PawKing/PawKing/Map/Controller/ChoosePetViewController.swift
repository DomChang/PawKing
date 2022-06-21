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
        
        navigationItem.title = "想與誰散步？"
        
        tableView.register(ChoosePetTableViewCell.self,
                           forCellReuseIdentifier: ChoosePetTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func style() {
        
        tableView.backgroundColor = .white
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoosePetTableViewCell.identifier)
                as? ChoosePetTableViewCell
        else {
            fatalError("Cannot dequeue ChoosePetTableViewCell")
        }
        
        cell.selectionStyle = .none
        
        cell.configureCell(pet: pets[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.didChoosePet(with: pets[indexPath.row])
        
        self.dismiss(animated: true)
    }
}
