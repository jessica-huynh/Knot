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
    var state: State = .ready
    
    enum Environment: String {
        case sandbox, development
        
        var linkKitValue: PLKEnvironment {
            switch self {
            case .sandbox: return .sandbox
            case .development: return .development
            }
        }
    }
    
    enum State {
        case ready
        case loading
    }
    
    private init() {
        let keys = KnotKeys()
        publicKey = keys.publicKey
        clientID = keys.clientID
        environment = .sandbox // Change Plaid environment from here
        secret = (environment == .sandbox) ? keys.secret_sandbox : keys.secret_development
    }
    
    // MARK: - Plaid Link Kit setup
    var linkKitConfiguration: PLKConfiguration {
        let configuration = PLKConfiguration(key: publicKey, env: environment.linkKitValue, product: .transactions)
        configuration.clientName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
        configuration.countryCodes = ["CA"]
        return configuration
    }
    
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
    
    // MARK: - API request helper function
    func request(for endpoint: PlaidAPI, onSuccess: @escaping (Response) throws -> Void) {
        provider.request(endpoint) {
            result in
            
            switch result {
            case .success(let response):
                do {
                    try onSuccess(response)
                } catch {
                    print("Error: \(error)")
                }
                
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    // MARK: - Linked Account Setup
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        request(for: .exchangeTokens(publicToken: publicToken)) {
            [weak self] response in
            guard let self = self else { return }
            
            let response = try ExchangeTokenResponse(data: response.data)
            
            if let data = try? JSONSerialization.data(
                withJSONObject: metadata!["institution"]!,
                options: []) {
                do {
                    let institution = try Institution(data: data)
                    self.setupAccounts(using: response.accessToken, for: institution)
                    
                } catch {
                    print("Could not parse JSON: \(error)")
                }
            }
        }
    }
    
    func setupAccounts(using accessToken: String, for institution: Institution) {
        storageManager.accessTokens.updateValue([], forKey: accessToken)
        
        request(for: .getAccounts(accessToken: accessToken)) {
            [weak self] response in
            guard let self = self else { return }
            
            let response = try GetAccountsResponse(data: response.data)
            let accounts = response.accounts
            
            for account in accounts {
                if account.type == .depository || account.type == .credit {
                    self.storageManager.accessTokens[accessToken]!.append(account.id)
                    self.storageManager.institutionsByID[account.id] = institution
                }
                
                if account.type == .depository {
                    self.storageManager.cashAccounts.append(account)
                } else if account.type == .credit {
                    self.storageManager.creditAccounts.append(account)
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
                NotificationCenter.default.post(name: .updatedAccounts, object: self)
            }
        }
    }
}
