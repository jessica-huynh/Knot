//
//  AccountDetailsViewModel.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

// Temp transaction data model
struct Transaction {
    let description: String
    let date: Date
    let amount: Double
}

protocol AccountDetailsViewModelSection {
    var type: AccountDetailsViewModel.SectionType { get }
    var title: String { get }
    var rowCount: Int { get }
}

class AccountDetailsViewModel: NSObject {
    enum SectionType: Int {
        case accounts
        case transactions
    }
    
    var sections = [AccountDetailsViewModelSection]()
    
    override init() {
        super.init()

        // Fake account data
        let account1 = Account(institution: "Scotiabank", accountNumber: "**** **** 4316")
        let account2 = Account(institution: "Tangerine", accountNumber: "**** **** 8625")
        let accounts = [account1, account2]
        
        let transaction1 = Transaction(description: "Uber", date: Date(), amount: 12.45)
        let transaction2 = Transaction(description: "Walmart", date: Date(), amount: 38.12)
        let transaction3 = Transaction(description: "Transfer", date: Date(), amount: -50.00)
        let transactions = [transaction1, transaction2, transaction3]
        
        sections.append(AccountDetailsViewModelAccounts(accounts: accounts))
        sections.append(AccountDetailsViewModelTransactions(transactions: transactions))
    }
    
    func hideAccounts() {
        for section in sections {
            if section.type == .accounts {
                sections.remove(at: section.type.rawValue)
                return
            }
        }
    }
}

// MARK: - Table View Data Source
extension AccountDetailsViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountBalanceCell", for: indexPath) as! AccountBalanceCell
            let section = section as! AccountDetailsViewModelAccounts
            cell.configure(for: section.accounts[indexPath.row])
            return cell
        case .transactions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            let section = section as! AccountDetailsViewModelTransactions
            cell.configure(for: section.transactions[indexPath.row])
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
    
    var balance: Double {
        return 7489.45
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
