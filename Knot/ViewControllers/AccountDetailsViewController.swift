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
    var spinnerView: UIView!
    var accountType: Account.AccountType!
    var viewModel: AccountDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNoValidAccountsAdded(_:)), name: .noValidAccountsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadingChanged(_:)), name: .loadingChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAddAccountTapped(_:)), name: .addAccountTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessfulLinking(_:)), name: .successfulLinking, object: nil)
        
        let reachedEndCell = UINib(nibName: "ReachedEndCell", bundle: nil)
        let loadingCell = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.register(reachedEndCell, forCellReuseIdentifier: "ReachedEndCell")
        tableView.register(loadingCell, forCellReuseIdentifier: "LoadingCell")
        
        spinnerView = createSpinnerView()
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
    
    // MARK: - Notification Selectors
    @objc func onSuccessfulLinking(_ notification:Notification) {
        showSpinner(spinnerView: spinnerView)
    }
    
    @objc func onNoValidAccountsAdded(_ notification:Notification) {
        removeSpinner(spinnerView: spinnerView)
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        viewModel = AccountDetailsViewModel(for: accountType)
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.reloadData()
        removeSpinner(spinnerView: spinnerView)
    }
    
    @objc func onLoadingChanged(_ notification:Notification) {
        tableView.reloadData()
    }
    
    @objc func onAddAccountTapped(_ notification:Notification) {
        presentPlaidLink()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let loadingChanged = Notification.Name("loadingChanged")
    static let addAccountTapped = Notification.Name("addAccountTapped")
}
