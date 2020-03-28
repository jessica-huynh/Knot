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
    var accountType: Account.AccountType!
    var viewModel: AccountDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedTransactions(_:)), name: .updatedTransactions, object: nil)
        
        let cellNib = UINib(nibName: "ReachedEndCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ReachedEndCell")
        
        title = navTitle
        viewModel = AccountDetailsViewModel(for: accountType)
        tableView.dataSource = viewModel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentPlaidLink()
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        viewModel = AccountDetailsViewModel(for: accountType)
        tableView.dataSource = viewModel
    }
    
    @objc func onUpdatedTransactions(_ notification:Notification) {
        tableView.reloadData()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedTransactions = Notification.Name("updatedTransactions")
}
