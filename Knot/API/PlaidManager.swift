//
//  PlaidManager.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-20.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import LinkKit
import Keys
import Moya

class PlaidManager {
    static let instance = PlaidManager()
    let provider = MoyaProvider<PlaidAPI>()
    let storageManager = StorageManager.instance
    
    let publicKey: String, clientID: String, secret: String, environment: Environment
    
    enum Environment: String {
        case sandbox, development
        
        var linkKitValue: PLKEnvironment {
            switch self {
            case .sandbox: return .sandbox
            case .development: return .development
            }
        }
    }
    
    private init() {
        let keys = KnotKeys()
        publicKey = keys.publicKey
        clientID = keys.clientID
        environment = .sandbox // Change Plaid environment from here
        secret = (environment == .sandbox) ? keys.secret_sandbox : keys.secret_development
    }
    
    // MARK: - Plaid Link Kit setup
    func setupPlaid() {
        PLKPlaidLink.setup(with: linkKitConfiguration) { (success, error) in
            if success {
                print("Plaid Link setup was successful")
            }
            else if let error = error {
                print("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                print("Unable to setup Plaid Link")
            }
        }
    }
    
    var linkKitConfiguration: PLKConfiguration {
        let configuration = PLKConfiguration(key: publicKey, env: environment.linkKitValue, product: .transactions)
        configuration.clientName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
        configuration.countryCodes = ["CA"]
        return configuration
    }
    
    // MARK: - API call helper functions
    func setupAccounts(using accountMetadata: AccountMetadata, for institution: Institution) {        
        provider.request(.getAccounts(accessToken: accountMetadata.accessToken)) {
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
                            self.storageManager.accountMetadata.updateValue(accountMetadata, forKey: account.id)
                            self.storageManager.institutions.updateValue(institution, forKey: account.id)
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
                    
                    print("\nAccess token: \(accountMetadata.accessToken)\n")
                    print("CASH: \(self.storageManager.cashAccounts)")
                    print("CREDIT: \(self.storageManager.creditAccounts)")
                    
                    NotificationCenter.default.post(name: .didLinkAccount, object: nil)
                    
                } catch {
                    print("Could not parse JSON: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    func getTransactions(using accessToken: String) {
        provider.request(.getTransactions(accessToken: accessToken)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let response = try GetTransactionsResponse(data: response.data)
                    let transactions = response.transactions
                    
                    print(transactions)
                    for transaction in transactions {
                        if let oldTransactions = self.storageManager.transactions[transaction.accountID] {
                            self.storageManager.transactions.updateValue(oldTransactions + [transaction], forKey: transaction.accountID)
                        } else {
                            self.storageManager.transactions.updateValue([transaction], forKey: transaction.accountID)
                        }
                    }
                    
                    NotificationCenter.default.post(name: .didUpdateTransactions, object: nil)
                    
                } catch {
                    print("Could not parse JSON: \(error)")
                }
                
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
}
