//
//  AccountDetailsViewModel.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

class AccountDetailsViewModel: NSObject {
    let storageManager = StorageManager.instance
    var accountType: Account.AccountType
    var sections = [AccountDetailsViewModelSection]()
    var accounts: [Account] = []
    var timeFrame: DateInterval
    var accountFilterItems: [AccountFilterItem] = []
    /**
     Indicates whether the posted transactions section is loading.
     - Note: There is no loading indicator for the pending transactions section.
     */
    var isLoading: Bool = false {
        didSet { NotificationCenter.default.post(name: .viewModelUpdated, object: self) }
    }
    
    enum SectionType: Int {
        case accounts
        case pendingTransactions
        case postedTransactions
    }
    
    init(for accountType: Account.AccountType) {
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: Date.today)!
        self.timeFrame = DateInterval(start: startDate, end: Date.today)
        self.accountType = accountType
        super.init()
        
        isLoading = true
        if accountType == .depository {
            accounts = storageManager.cashAccounts
            sections.append(AccountDetailsViewModelTransactions(title: "Transactions"))
            
        } else if accountType == .credit {
            accounts = storageManager.creditAccounts
            sections.append(AccountDetailsViewModelPendingTransactions())
            sections.append(AccountDetailsViewModelTransactions(title: "Posted Transactions"))
            updatePendingTransactions {
                NotificationCenter.default.post(name: .viewModelUpdated, object: self)
            }
        }
 
        for account in accounts {
            accountFilterItems.append(AccountFilterItem(account: account, isChecked: true))
        }
        
        sections.insert(AccountDetailsViewModelAccounts(accounts: accounts), at: 0)
        updatePostedTransactions {
            [weak self] in
            guard let self = self else { return }
            self.isLoading = false
        }
    }
    
    // MARK:- Fetch Transactions
    func updatePendingTransactions(completionHandler: @escaping () -> Void) {
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: Date.today)!
        
        PlaidManager.instance.getTransactions(for: accounts, startDate: startDate, endDate: Date.today) {
            [weak self] transactions in
            guard let self = self else { return }

            let pendingTransactions = transactions.filter({ $0.pending })
            let pendingTransactionsSection = self.sections[1] as! AccountDetailsViewModelPendingTransactions
            pendingTransactionsSection.unfilteredTransactions = pendingTransactions
            pendingTransactionsSection.filteredTransactions = pendingTransactions
            completionHandler()
        }
    }
    
    
    func updatePostedTransactions(completionHandler: @escaping () -> Void) {
        PlaidManager.instance.getTransactions(for: accounts, startDate: timeFrame.start, endDate: timeFrame.end) {
            [weak self] transactions in
            guard let self = self else { return }
            
            if self.accountType == .depository {
                let transactionsSection = self.sections[1] as! AccountDetailsViewModelTransactions
                transactionsSection.unfilteredTransactions = transactions
                transactionsSection.filteredTransactions = transactions
                completionHandler()
                return
            }
            
            // If account is a credit card:
            let cutoffDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: Date())!
            let mightIncludePendingTransactions = self.timeFrame.end > cutoffDate
            let postedTransactions = mightIncludePendingTransactions ?
                    transactions.filter({ !$0.pending }) : transactions

            let postedTransactionsSection = self.sections[2] as! AccountDetailsViewModelTransactions
            postedTransactionsSection.unfilteredTransactions = postedTransactions
            postedTransactionsSection.filteredTransactions = postedTransactions
            completionHandler()
        }
    }
}

// MARK: - View Model Data
protocol AccountDetailsViewModelSection {
    var type: AccountDetailsViewModel.SectionType { get }
    var title: String { get }
    var rowCount: Int { get }
}

class AccountDetailsViewModelAccounts: AccountDetailsViewModelSection {
    var accounts: [Account]
    
    var type: AccountDetailsViewModel.SectionType {
        .accounts
    }
    
    var title: String {
        return ""
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
