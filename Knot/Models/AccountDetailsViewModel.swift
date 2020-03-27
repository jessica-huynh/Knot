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
        case pendingTransactions
        case postedTransactions
    }
    
    var sections = [AccountDetailsViewModelSection]()
    
    init(for accountType: Account.AccountType) {
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
        }
        
        sections.append(AccountDetailsViewModelAccounts(accounts: accounts))
        
        getTransactions(for: accounts, with: accountType)
    }
    
    // MARK:- Helper function
    func getTransactions(for accounts: [Account], with accountType: Account.AccountType) {
        var transactions: [Transaction] = []
        let dispatch = DispatchGroup()
        
        for account in accounts {
            dispatch.enter()
            let accessToken = storageManager.accessToken(for: account.id)!
            
            PlaidManager.instance.request(for: .getTransactions(accessToken: accessToken, accountIDs: [account.id])) {
                response in
                
                let response = try GetTransactionsResponse(data: response.data)
                
                transactions.append(contentsOf: response.transactions)
                dispatch.leave()
                
                }
        }
        
        dispatch.notify(queue: .main) {
            transactions.sort(by: >)
            if accountType == .depository {
                self.sections.append(AccountDetailsViewModelTransactions(title: "Transactions", transactions: transactions))
            } else {
                var pendingTransactions: [Transaction] = []
                for index in 0...transactions.count - 1 {
                    if transactions[index].pending {
                        pendingTransactions.append(transactions.remove(at: index))
                    }
                }
                self.sections.append(AccountDetailsViewModelPendingTransactions(transactions: pendingTransactions))
                self.sections.append(AccountDetailsViewModelTransactions(title: "Posted Transactions", transactions: transactions))
            }
            
            NotificationCenter.default.post(name: .updatedTransactions, object: nil)
        }
    }
}

// MARK: - Table View Data Source
extension AccountDetailsViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section].type
        
        if sections[section].rowCount == 0 {
            // Only 'Pending Transactions' and 'Posted Transactions' can have a
            // row count of 0
            return 1
        }
        
        if sectionType == .postedTransactions {
            return sections[section].rowCount + 1
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
            
        case .postedTransactions:
            let section = section as! AccountDetailsViewModelTransactions
            if section.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionsFoundCell") as! TransactionCell
                return cell
            }
            
            if indexPath.row == section.transactions.count {
                return tableView.dequeueReusableCell(withIdentifier: "ReachedEndCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.configure(using: section.transactions[indexPath.row])
            return cell
            
        case .pendingTransactions:
            let section = section as! AccountDetailsViewModelPendingTransactions
            if section.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoPendingTransactionsCell") as! TransactionCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
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
    var title: String
    var transactions: [Transaction]
    
    var type: AccountDetailsViewModel.SectionType {
        return .postedTransactions
    }
    
    var rowCount: Int {
        return transactions.count
    }
    
    init(title: String, transactions: [Transaction]) {
        self.title = title
        self.transactions = transactions
    }
}

class AccountDetailsViewModelPendingTransactions: AccountDetailsViewModelSection {
    var transactions: [Transaction]
    
    var type: AccountDetailsViewModel.SectionType {
        return .pendingTransactions
    }
    
    var title: String {
        return "Pending Transactions"
    }
    
    var rowCount: Int {
        return transactions.count
    }
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
}
