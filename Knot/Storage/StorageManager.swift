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
    
    var accessTokens: [String : [String]] = [:]
    var institutionsByID: [String : Institution] = [:]
    
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
    
    /// List of transactions for all accounts dated in the last 30 days.
    var recentTransactions: [Transaction] = []
    
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
    
    func getAccessToken(for accountID: String) -> String? {
        for (accessToken, accountIDs) in accessTokens {
            if accountIDs.contains(accountID) {
                return accessToken
            }
        }
        return nil
    }
}
