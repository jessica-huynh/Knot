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
    var accounts: [Account] = []
    var accountType: Account.AccountType
    
    enum SectionType: Int {
        case accounts
        case pendingTransactions
        case postedTransactions
    }
    
    var sections = [AccountDetailsViewModelSection]()
    
    init(for accountType: Account.AccountType) {
        self.accountType = accountType
        super.init()
        
        if accountType == .depository {
            accounts = storageManager.cashAccounts
            sections.append(AccountDetailsViewModelTransactions(title: "Transactions"))
            
        } else if accountType == .credit {
            accounts = storageManager.creditAccounts
            sections.append(AccountDetailsViewModelPendingTransactions())
            sections.append(AccountDetailsViewModelTransactions(title: "Posted Transactions"))
            updatePendingTransactions()
        }
 
        sections.insert(AccountDetailsViewModelAccounts(accounts: accounts), at: 0)
        
        let today = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: today)!
        updatePostedTransactions(startDate: startDate, endDate: today)
    }
    
    // MARK:- Fetch Transactions
    func updatePendingTransactions() {
        let today = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: today)!
        
        PlaidManager.instance.getTransactions(for: accounts, startDate: startDate, endDate: today) {
            [weak self] transactions in
            guard let self = self else { return }

            var pendingTransactions: [Transaction] = []
            for transaction in transactions {
                if transaction.pending {
                    pendingTransactions.append(transaction)
                }
            }
            
            let pendingTransactionsSection = self.sections[1] as! AccountDetailsViewModelPendingTransactions
            pendingTransactionsSection.transactions = pendingTransactions
            
            NotificationCenter.default.post(name: .updatedTransactions, object: nil)
        }
    }
    
    
    func updatePostedTransactions(startDate: Date, endDate: Date) {
        PlaidManager.instance.getTransactions(for: accounts, startDate: startDate, endDate: endDate) {
            [weak self] response in
            guard let self = self else { return }
            
            var transactions = response
            if self.accountType == .depository {
                transactions.sort(by: >)
                let transactionsSection = self.sections[1] as! AccountDetailsViewModelTransactions
                transactionsSection.transactions = transactions
                
                NotificationCenter.default.post(name: .updatedTransactions, object: nil)
                return
            }
            
            // If account is a credit card:
            let cutoffDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: Date())!
            let mightIncludePendingTransactions = endDate > cutoffDate
            
            var postedTransactions: [Transaction] = []
            if mightIncludePendingTransactions {
                for transaction in transactions {
                    if !transaction.pending {
                        postedTransactions.append(transaction)
                    }
                }
            } else {
                postedTransactions = transactions
            }

            let postedTransactionsSection = self.sections[2] as! AccountDetailsViewModelTransactions
            postedTransactionsSection.transactions = postedTransactions
            
            NotificationCenter.default.post(name: .updatedTransactions, object: nil)
        }
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
    
    init(accounts: [Account] = []) {
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
    
    init(title: String, transactions: [Transaction] = []) {
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
    
    init(transactions: [Transaction] = []) {
        self.transactions = transactions
    }
}
