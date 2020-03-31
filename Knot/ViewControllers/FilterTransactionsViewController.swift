//
//  FilterTransactionsViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class FilterTransactionsViewController: UITableViewController {
    var delegate: FilterTransactionsViewControllerDelegate?
    var accountFilterItems: [AccountFilterItem] = []
    var checkedAccounts: [AccountFilterItem] {
        return accountFilterItems.filter { $0.isChecked }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.filterTransactionsViewController(self, filteredAccountsOnClose: accountFilterItems)
        dismiss(animated: true, completion: nil)
    }
    
    func configureCheckmark(for cell: UITableViewCell, at indexPath: IndexPath) {
        let item = accountFilterItems[indexPath.row]
        cell.accessoryType = item.isChecked ? .checkmark : .none
    }
    
    // MARK: - Table View Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountFilterItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkedAccounts.count == 1 && checkedAccounts.contains(accountFilterItems[indexPath.row])  {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let filterItem = accountFilterItems[indexPath.row]
            accountFilterItems[indexPath.row] = filterItem.with(account: filterItem.account, isChecked: !filterItem.isChecked)
            configureCheckmark(for: cell, at: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountFilterCell", for: indexPath)
        let account = accountFilterItems[indexPath.row].account
        
        cell.textLabel?.text = account.name
        
        if let mask = account.mask {
            cell.textLabel?.text! += " (\(mask))"
        }
        
        cell.detailTextLabel?.text = account.institution.name
        configureCheckmark(for: cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose at least one account:"
    }
}

// MARK: - Delegate Protocol
protocol FilterTransactionsViewControllerDelegate: class {
    func filterTransactionsViewController(_ : FilterTransactionsViewController, filteredAccountsOnClose accountFilterItems: [AccountFilterItem])
}
