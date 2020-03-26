//
//  HomeViewController+PlaidLink.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit
import LinkKit

extension HomeViewController {
    func setupAccounts(using accessToken: String, for institution: Institution) {
        storageManager.accessTokens.updateValue([], forKey: accessToken)
        
        plaidManager.request(for: .getAccounts(accessToken: accessToken)) {
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
                self.updateLabels()
                self.updateRecentTransactions(using: accessToken)
            }
        }
    }
    
    func updateRecentTransactions(using accessToken: String) {
        plaidManager.request(for: .getTransactions(accessToken: accessToken, accountIDs: storageManager.accessTokens[accessToken])) {
            [weak self] response in
            guard let self = self else { return }
            
            let response = try GetTransactionsResponse(data: response.data)
            self.recentTransactions = response.transactions
            
            print(self.recentTransactions)
            if !self.recentTransactions.isEmpty {
                self.noTransactionsFoundLabel.isHidden = self.recentTransactions.isEmpty ? false : true
                self.transactionCollectionView.reloadData()
            }
        }
    }
        
    // MARK: - Plaid Link handlers
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        plaidManager.request(for: .exchangeTokens(publicToken: publicToken)) {
            [weak self] response in
            guard let self = self else { return }
            
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
extension HomeViewController : PLKPlaidLinkViewDelegate{
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
