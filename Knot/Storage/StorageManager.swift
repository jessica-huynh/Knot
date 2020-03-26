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
    
    private init() {
        // Load from CoreData here
    }
    
    // MARK: - Helper Functions
    func accountType(for accountID: String) -> Account.AccountType {
        for account in cashAccounts {
            if account.id == accountID {
                return .depository
            }
        }
        return .credit
    }
    
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
}
