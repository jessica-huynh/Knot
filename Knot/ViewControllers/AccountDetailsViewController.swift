//
//  AccountDetailsViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UITableViewController {
    var navTitle: String!
    var viewModel: AccountDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = navTitle
        tableView?.dataSource = viewModel
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
    }
}
