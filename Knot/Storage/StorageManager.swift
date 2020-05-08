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
    var isFetchingUpdates = false
    
    /// Plaid access token -> associated account IDs
    var accessTokens: [String : [String]] = [:]
    /// accound ID -> institution
    var institutionsByID: [String : Institution] = [:]
    /// Cash accounts that belong to the user
    var cashAccounts: [Account] = []
    /// Credit accounts that belong to the user
    var creditAccounts: [Account] = []
    /// All accounts including cash and credit accounts that belong to the user
    var accounts: [Account] { return cashAccounts + creditAccounts }
    
    private init() {
        loadData()
    }
    
    // MARK: - Helper Functions
    /// Returns the access token for a given account ID
    func accessToken(for accountID: String) -> String? {
        for (accessToken, accountIDs) in accessTokens {
            if accountIDs.contains(accountID) {
                return accessToken
            }
        }
        return nil
    }
    
    /// Returns the account object for a given account ID
    func account(for accountID: String) -> Account? {
        for account in accounts {
            if account.id == accountID {
                return account
            }
        }
        return nil
    }
    
    func addAccounts(using accessToken: String, for institution: Institution) {
        accessTokens.updateValue([], forKey: accessToken)
        
        PlaidManager.instance.request(for: .getAccounts(accessToken: accessToken)) {
            [weak self] response in
            guard let self = self else { return }
            
            let response = try GetAccountsResponse(data: response.data)
            let accounts = response.accounts
            
            for account in accounts {
                if self.accounts.contains(where: { $0.id == account.id }) {
                    // Ignore duplicate accounts
                    continue
                }
                
                let account = account.updateDateAdded()
                if account.type == .depository || account.type == .credit {
                    self.accessTokens[accessToken]!.append(account.id)
                    self.institutionsByID[account.id] = institution
                }
                
                if account.type == .depository {
                    self.cashAccounts.append(account)
                } else if account.type == .credit {
                    self.creditAccounts.append(account)
                }
            }
            
            if self.accessTokens[accessToken]!.isEmpty {
                // If no valid accounts were added, remove the access token from storage
                self.accessTokens.removeValue(forKey: accessToken)
                NotificationCenter.default.post(name: .noValidAccountsAdded, object: self)
            } else {
                NotificationCenter.default.post(name: .updatedAccounts, object: self)
                self.saveData()
            }
        }
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
        saveData()
    }
    
    func deleteAllAccounts() {
        accessTokens = [:]
        institutionsByID = [:]
        cashAccounts = []
        creditAccounts = []
        NotificationCenter.default.post(name: .updatedAccounts, object: self)
        saveData()
    }
    
    // MARK: - plist data storage
    private struct Storage: Codable {
        let accessTokens: [String : [String]]
        let institutionsByID: [String : Institution]
        let cashAccounts: [Account]
        let creditAccounts: [Account]
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Knot.plist")
    }
    
    func loadData() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                let storage = try decoder.decode(Storage.self, from: data)
                accessTokens = storage.accessTokens
                institutionsByID = storage.institutionsByID
                cashAccounts = storage.cashAccounts
                creditAccounts = storage.creditAccounts
            } catch {
                print("Load data error: \(error)")
            }
        }
    }
    
    func saveData() {
        let storage = Storage(accessTokens: accessTokens, institutionsByID: institutionsByID, cashAccounts: cashAccounts, creditAccounts: creditAccounts)
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(storage)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Save data error: \(error)")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedAccounts = Notification.Name("updatedAccounts")
    static let noValidAccountsAdded = Notification.Name("noValidAccountsAdded")
}
