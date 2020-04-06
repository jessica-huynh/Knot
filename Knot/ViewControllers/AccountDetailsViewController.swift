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
        NotificationCenter.default.addObserver(self, selector: #selector(onAddAccountTapped(_:)), name: .addAccountTapped, object: nil)
        
        let cellNib = UINib(nibName: "ReachedEndCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ReachedEndCell")
        
        title = navTitle
        viewModel = AccountDetailsViewModel(for: accountType)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterTransactions",
            let navigationController = segue.destination as? UINavigationController,
            let controller = navigationController.topViewController as? FilterTransactionsViewController {
            controller.delegate = viewModel
            controller.accountFilterItems = viewModel.accountFilterItems
        }
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        viewModel = AccountDetailsViewModel(for: accountType)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.reloadData()
    }
    
    @objc func onUpdatedTransactions(_ notification:Notification) {
        tableView.reloadData()
    }
    
    @objc func onAddAccountTapped(_ notification:Notification) {
        presentPlaidLink()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedTransactions = Notification.Name("updatedTransactions")
    static let addAccountTapped = Notification.Name("addAccountTapped")
}
