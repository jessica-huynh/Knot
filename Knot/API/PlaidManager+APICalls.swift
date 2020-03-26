//
//  PlaidManager+APICalls.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

extension PlaidManager {
    func handleSuccessfulLinking(using publicToken: String, metadata: [String : Any]?) {
        provider.request(.exchangeTokens(publicToken: publicToken)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let accountMetadata = try AccountMetadata(data: response.data)
                    
                    if let data = try? JSONSerialization.data(
                        withJSONObject: metadata!["institution"]!,
                        options: []) {
                        do {
                            let institution = try Institution(data: data)
                            self.setupAccounts(using: accountMetadata.accessToken, for: institution)
                            
                        } catch {
                            print("Could not parse JSON: \(error)")
                        }
                    }
                } catch {
                    print("Could not parse JSON: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    func setupAccounts(using accessToken: String, for institution: Institution) {
        storageManager.accessTokens.updateValue([], forKey: accessToken)
        
        provider.request(.getAccounts(accessToken: accessToken)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let response = try GetAccountsResponse(data: response.data)
                    let accounts = response.accounts
                    
                    for account in accounts {
                        switch account.type {
                        case .depository, .credit:
                            self.storageManager.accessTokens[accessToken]!.append(account.id)
                            self.storageManager.institutionsByID[account.id] = institution
                        case .investment, .loan, .other:
                            break
                        }
                        
                        switch account.type {
                        case .depository:
                            self.storageManager.cashAccounts.append(account)
                        case .credit:
                            self.storageManager.creditAccounts.append(account)
                        case .investment, .loan, .other:
                            break
                        }
                    }
                    
                    print("\nAccess token: \(accessToken)\n")
                    print("CASH: \(self.storageManager.cashAccounts)")
                    print("CREDIT: \(self.storageManager.creditAccounts)")
                    
                    // If no valid accounts types were added, remove the access token from storage
                    if self.storageManager.accessTokens[accessToken]!.isEmpty {
                        self.storageManager.accessTokens.removeValue(forKey: accessToken)
                        // TODO: Notify user of no valid account types
                    } else {
                        NotificationCenter.default.post(name: .didLinkAccount, object: nil)
                        self.updateRecentTransactions(using: accessToken)
                    }
                    
                } catch {
                    print("Could not parse JSON: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    func updateRecentTransactions(using accessToken: String) {
        provider.request(.getTransactions(accessToken: accessToken, accountIDs: storageManager.accessTokens[accessToken])) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let response = try GetTransactionsResponse(data: response.data)
                    let transactions = response.transactions
                    
                    print(transactions)
                    if !transactions.isEmpty {
                        self.storageManager.recentTransactions.append(contentsOf: transactions)
                        self.storageManager.recentTransactions.sort(by: >)
                        NotificationCenter.default.post(name: .didUpdateTransactions, object: nil)
                    }
                    
                } catch {
                    print("Could not parse JSON: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    func getTransactions(for accounts: [Account]) {
        var transactions: [Transaction] = []
        let dispatch = DispatchGroup()
        for account in accounts {
            dispatch.enter()
            let accessToken = storageManager.getAccessToken(for: account.id)!
            
            provider.request(.getTransactions(accessToken: accessToken, accountIDs: [account.id])) {
                result in
                
                switch result {
                case .success(let response):
                    do {
                        let response = try GetTransactionsResponse(data: response.data)
                        
                        transactions.append(contentsOf: response.transactions)
                        print("----Account: \(account)----\n\(transactions)\n")
                        
                    } catch {
                        print("Could not parse JSON: \(error)")
                    }
                    dispatch.leave()
                    
                case .failure(let error):
                    print("Network request failed: \(error)")
                    print(try! error.response!.mapJSON())
                    dispatch.leave()
                }
            }
        }
        dispatch.notify(queue: .main) {
            //transactions.sorted(by: >)
        }
    }
}
