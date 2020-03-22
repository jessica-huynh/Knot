//
//  OverviewViewController+PlaidLink.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit
import LinkKit

extension OverviewViewController {
    func setupAccounts(using exchangeTokenResponse: ExchangeTokenResponse, for institution: Institution) {
        provider.request(.getAccounts(accessToken: exchangeTokenResponse.accessToken)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let retrieveAccountsResponse = try GetAccountsResponse(data: response.data)
                    let accounts = retrieveAccountsResponse.accounts
                    
                    for account in accounts {
                        switch account.type {
                        case .depository, .credit, .investment:
                            self.metadata.updateValue(exchangeTokenResponse, forKey: account.id)
                            self.institutions.updateValue(institution, forKey: account.id)
                        case .loan, .other:
                            break
                        }
                        
                        switch account.type {
                        case .depository:
                            self.cashAccounts.append(account)
                        case .credit:
                            self.creditAccounts.append(account)
                        case .investment:
                            self.investmentAccounts.append(account)
                        case .loan, .other:
                            break
                        }
                    }
                    
                    print("CASH: \(self.cashAccounts)")
                    print("CREDIT: \(self.creditAccounts)")
                    print("INVESTMENT: \(self.investmentAccounts)")
                    
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
    
    // MARK: - Plaid Link handlers
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        provider.request(.exchangeTokens(publicToken: publicToken)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let exchangeTokenResponse = try ExchangeTokenResponse(data: response.data)
                    
                    if let data = try? JSONSerialization.data(
                        withJSONObject: metadata!["institution"]!,
                        options: []) {
                        do {
                            let institution = try Institution(data: data)
                            self.setupAccounts(using: exchangeTokenResponse, for: institution)
                            
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
    
    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }
    
    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Plaid Link setup
    func presentPlaidLink() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: plaidManager.linkKitConfiguration, delegate: linkViewDelegate)
        
        present(linkViewController, animated: true)
    }
    
    func presentPlaidLinkInUpdateMode() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(publicToken: "<#GENERATED_PUBLIC_TOKEN#>", delegate: linkViewDelegate)
        
        present(linkViewController, animated: true)
    }
}

// MARK: - PLKPlaidLinkViewDelegate Protocol
extension OverviewViewController : PLKPlaidLinkViewDelegate{
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            print("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                print("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error, metadata: metadata)
            }
            else {
                print("Plaid link exited with metadata: \(metadata ?? [:])")
                self.handleExitWithMetadata(metadata)
            }
        }
    }
}
