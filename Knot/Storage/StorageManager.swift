//
//  StorageManager.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class StorageManager {
    static let instance = StorageManager()
    
    var accountMetadata: [String : AccountMetadata] = [:]
    var institutions: [String : Institution] = [:]
    
    var cashAccounts: [Account] = [] {
        didSet {
            if (oldValue.isEmpty && !cashAccounts.isEmpty)
                || (!oldValue.isEmpty && cashAccounts.isEmpty) {
                NotificationCenter.default.post(name: .cashIsEmptyChanged, object: nil)
            }
        }
    }
    
    var creditAccounts: [Account] = [] {
        didSet {
            if (oldValue.isEmpty && !creditAccounts.isEmpty)
                || (!oldValue.isEmpty && creditAccounts.isEmpty) {
                NotificationCenter.default.post(name: .creditCardsIsEmptyChanged, object: nil)
            }
        }
    }
    
    var transactions: [String : [Transaction]] = [:]
    
    var allTransactions: [Transaction] {
        let combinedTransactionLists = transactions.values
        var mergedTransactionList: [Transaction] = []
        for transactionList in combinedTransactionLists {
            mergedTransactionList += transactionList
        }
        
        mergedTransactionList.sort(by: >)
        return mergedTransactionList
    }
    
    private init() {
        // Load from CoreData here
    }
    
    func accountType(for accountID: String) -> Account.AccountType {
        for account in cashAccounts {
            if account.id == accountID {
                return .depository
            }
        }
        return .credit
    }
    
    func getTransactions(for accounts: [Account]) -> [Transaction] {
        var result: [Transaction] = []
        
        for account in accounts {
            result += transactions[account.id] ?? []
        }
        
        result.sort(by: >)
        return result
    }
}
