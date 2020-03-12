//
//  AccountDetailsViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UITableViewController {
    
    var accountType: String?
    let viewModel = AccountDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = accountType!
        tableView?.dataSource = viewModel
    }

}
