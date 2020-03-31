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
    var accountType: Account.AccountType
    var accounts: [Account] = []
    var timeFrame: DateInterval
    var accountFilterItems: [AccountFilterItem] = []
    
    enum SectionType: Int {
        case accounts
        case pendingTransactions
        case postedTransactions
    }
    
    var sections = [AccountDetailsViewModelSection]()
    
    init(for accountType: Account.AccountType) {
        let today = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: today)!
        self.timeFrame = DateInterval(start: startDate, end: today)
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
 
        for account in accounts {
            accountFilterItems.append(AccountFilterItem(account: account, isChecked: true))
        }
        
        sections.insert(AccountDetailsViewModelAccounts(accounts: accounts), at: 0)
        updatePostedTransactions()
    }
    
    // MARK:- Fetch Transactions
    func updatePendingTransactions() {
        let today = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: today)!
        
        PlaidManager.instance.getTransactions(for: accounts, startDate: startDate, endDate: today) {
            [weak self] transactions in
            guard let self = self else { return }

            let pendingTransactions = transactions.filter({ $0.pending })
            let pendingTransactionsSection = self.sections[1] as! AccountDetailsViewModelPendingTransactions
            pendingTransactionsSection.unfilteredTransactions = pendingTransactions
            
            self.filterTransactions()
        }
    }
    
    
    func updatePostedTransactions() {
        PlaidManager.instance.getTransactions(for: accounts, startDate: timeFrame.start, endDate: timeFrame.end) {
            [weak self] transactions in
            guard let self = self else { return }
            
            if self.accountType == .depository {
                let transactionsSection = self.sections[1] as! AccountDetailsViewModelTransactions
                transactionsSection.unfilteredTransactions = transactions
                
                self.filterTransactions()
                return
            }
            
            // If account is a credit card:
            let cutoffDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: Date())!
            let mightIncludePendingTransactions = self.timeFrame.end > cutoffDate
            let postedTransactions = mightIncludePendingTransactions ?
                    transactions.filter({ !$0.pending }) : transactions

            let postedTransactionsSection = self.sections[2] as! AccountDetailsViewModelTransactions
            postedTransactionsSection.unfilteredTransactions = postedTransactions
            
            self.filterTransactions()
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
    var unfilteredTransactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    
    var type: AccountDetailsViewModel.SectionType {
        return .postedTransactions
    }
    
    var rowCount: Int {
        return filteredTransactions.count
    }
    
    init(title: String) {
        self.title = title
    }
}

class AccountDetailsViewModelPendingTransactions: AccountDetailsViewModelSection {
    var unfilteredTransactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    
    var type: AccountDetailsViewModel.SectionType {
        return .pendingTransactions
    }
    
    var title: String {
        return "Pending Transactions"
    }
    
    var rowCount: Int {
        return filteredTransactions.count
    }
}
