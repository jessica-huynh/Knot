//
//  AccountDetailsViewModel.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

protocol AccountDetailsViewModelSection {
    var type: AccountDetailsViewModel.SectionType { get }
    var title: String { get }
    var rowCount: Int { get }
}

class AccountDetailsViewModel: NSObject {
    let storageManager = StorageManager.instance
    
    enum SectionType: Int {
        case accounts
        case transactions
    }
    
    var sections = [AccountDetailsViewModelSection]()
    
    init(for accountType: Account.AccountType?) {
        super.init()
        
        var accounts: [Account]!
        
        switch accountType {
        case .credit:
            accounts = storageManager.creditAccounts
        case .depository:
            accounts = storageManager.cashAccounts
        case .investment, .loan, .other:
            print("WARNING: Not currently supporting loan/other account types.")
            return
        case .none:
            // No account type given means we are only going to show transactions.
            sections.append(AccountDetailsViewModelTransactions(transactions: storageManager.allTransactions))
            return
        }
        
        sections.append(AccountDetailsViewModelAccounts(accounts: accounts))
        
        let transactions = self.setupTransactions(for: accounts)
        sections.append(AccountDetailsViewModelTransactions(transactions: transactions))
    }
    
    func setupTransactions(for accounts: [Account]) -> [Transaction] {
        var transactions: [Transaction] = []
        
        for account in accounts {
            transactions += storageManager.transactions[account.id] ?? []
        }
        
        transactions.sort(by: >)
        return transactions
    }
}

// MARK: - Table View Data Source
extension AccountDetailsViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && sections[section].rowCount == 0 {
            return 1
        }
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountBalanceCell", for: indexPath) as! AccountBalanceCell
            let section = section as! AccountDetailsViewModelAccounts
            
            cell.configure(using: section.accounts[indexPath.row])
            return cell
            
        case .transactions:
            let section = section as! AccountDetailsViewModelTransactions
            if section.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionsFoundCell", for: indexPath) as! TransactionCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            cell.configure(using: section.transactions[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - View Model Data
class AccountDetailsViewModelAccounts: AccountDetailsViewModelSection {
    var accounts: [Account]
    
    var type: AccountDetailsViewModel.SectionType {
        .accounts
    }
    
    var title: String {
        return "Accounts"
    }
    
    var rowCount: Int {
        return accounts.count
    }
    
    init(accounts: [Account]) {
        self.accounts = accounts
    }
}

class AccountDetailsViewModelTransactions: AccountDetailsViewModelSection {
    var transactions: [Transaction]
    
    var type: AccountDetailsViewModel.SectionType {
        return .transactions
    }
    
    var title: String {
        return "Transactions"
    }
    
    var rowCount: Int {
        return transactions.count
    }
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
}
