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
    
    // <key, value>: <access token, associated account IDs>
    // Reduces number of requests to Plaid when fetching transactions for
    // all acounts
    var accessTokens: [String : [String]] = [:]
    var institutionsByID: [String : Institution] = [:]
    var cashAccounts: [Account] = []
    var creditAccounts: [Account] = []
    var accounts: [Account] { return cashAccounts + creditAccounts }
    
    private init() {
        // Load from CoreData here
    }
    
    // MARK: - Helper Functions
    func accessToken(for accountID: String) -> String? {
        for (accessToken, accountIDs) in accessTokens {
            if accountIDs.contains(accountID) {
                return accessToken
            }
        }
        return nil
    }
    
    func account(for accountID: String) -> Account? {
        for account in cashAccounts {
            if account.id == accountID {
                return account
            }
        }
        
        for account in creditAccounts {
            if account.id == accountID {
                return account
            }
        }
        return nil
    }
    
    func deleteAccount(account: Account) {
        let oldAccountIDs = accessTokens[account.accessToken]!
        let newAccountIDs = oldAccountIDs.filter { $0 != account.id }
        if !newAccountIDs.isEmpty {
            accessTokens.updateValue(newAccountIDs, forKey: account.accessToken)
        } else {
            // If the account deleted was the last linked account for its access token
            accessTokens.removeValue(forKey: account.accessToken)
        }
        
        institutionsByID.removeValue(forKey: account.id)
        
        if account.type == .depository {
            cashAccounts.removeAll { $0.id == account.id }
        } else if account.type == .credit {
            creditAccounts.removeAll { $0.id == account.id }
        }
        NotificationCenter.default.post(name: .updatedAccounts, object: self)
    }
}
