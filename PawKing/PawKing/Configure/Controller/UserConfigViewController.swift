//
//  UserConfigViewController.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import UIKit

class UserConfigViewController: BaseConfigViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setup() {
        super.setup()
        
        tableView.delegate = self
    }
    
    override func style() {
        super.style()
    }
    
    override func layout() {
        super.layout()
        
    }
    
    override func didTapConfirm() {
        <#code#>
    }

}

extension UserConfigViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
    }
    
    
}
