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
    var sections: [AccountDetailsViewModelSection] = []
    var accounts: [Account] = []
    /**
     Time frame of the displayed *posted* transactions.
     - Note: Pending transactions are not subject to changing time frames as this app assumes that pending transactions always fall within the last 14 days.
     */
    var timeFrame: DateInterval
    /// Keeps track of which accounts the user is and isn't using to filter the displayed transactions.
    var accountFilterItems: [AccountFilterItem] = []
    /// Indicates whether the *posted* transactions section is loading.
    var isLoading: Bool = false {
        didSet { NotificationCenter.default.post(name: .viewModelUpdated, object: self) }
    }
    
    enum SectionType {
        case accounts, pendingTransactions, postedTransactions
    }
    
    init(for accountType: Account.AccountType) {
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: Date.today)!
        self.timeFrame = DateInterval(start: startDate, end: Date.today)
        self.accountType = accountType
        super.init()
        
        isLoading = true
        if accountType == .depository {
            accounts = storageManager.cashAccounts
            sections.append(PostedTransactionsSection(title: "Transactions"))
            
        } else if accountType == .credit {
            accounts = storageManager.creditAccounts
            sections.append(PendingTransactionsSection())
            sections.append(PostedTransactionsSection(title: "Posted Transactions"))
            updatePendingTransactions {
                NotificationCenter.default.post(name: .viewModelUpdated, object: self)
            }
        }
 
        for account in accounts {
            accountFilterItems.append(AccountFilterItem(account: account, isChecked: true))
        }
        
        sections.insert(AccountsSection(accounts: accounts), at: 0)
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
            let pendingTransactionsSection = self.sections[1] as! PendingTransactionsSection
            pendingTransactionsSection.unfilteredTransactions = pendingTransactions
            pendingTransactionsSection.filteredTransactions = pendingTransactions
            completionHandler()
        }
    }
    
    
    func updatePostedTransactions(completionHandler: @escaping () -> Void) {
        PlaidManager.instance.getTransactions(for: accounts, startDate: timeFrame.start, endDate: timeFrame.end) {
            [weak self] transactions in
            guard let self = self else { return }
            
            var postedTransactions = transactions
            if self.accountType == .credit {
                let cutoffDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: Date())!
                let mightIncludePendingTransactions = self.timeFrame.end > cutoffDate
                if mightIncludePendingTransactions {
                    postedTransactions = transactions.filter({ !$0.pending })
                }
            }

            let postedTransactionsSection = self.sections.last! as! PostedTransactionsSection
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

extension AccountDetailsViewModel {
    class AccountsSection: AccountDetailsViewModelSection {
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

    class PostedTransactionsSection: AccountDetailsViewModelSection {
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

    class PendingTransactionsSection: AccountDetailsViewModelSection {
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
}
