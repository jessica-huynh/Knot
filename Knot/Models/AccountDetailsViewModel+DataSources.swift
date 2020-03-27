//
//  AccountDetailsViewModel+DataSources.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-27.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View Data Source
extension AccountDetailsViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section].type
        
        if sectionType == .accounts { return 1 }
        
        if sections[section].rowCount == 0 { return 1 }
        
        if sectionType == .postedTransactions { return sections[section].rowCount + 1 }
        
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            cell.setupAccountCollectionView(with: self)
            
            return cell
            
        case .postedTransactions:
            let section = section as! AccountDetailsViewModelTransactions
            if section.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionsFoundCell") as! TransactionCell
                return cell
            }
            
            if indexPath.row == section.transactions.count {
                return tableView.dequeueReusableCell(withIdentifier: "ReachedEndCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.configure(using: section.transactions[indexPath.row])
            return cell
            
        case .pendingTransactions:
            let section = section as! AccountDetailsViewModelPendingTransactions
            if section.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoPendingTransactionsCell") as! TransactionCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.configure(using: section.transactions[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - Collection View Data Source
extension AccountDetailsViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.first!.rowCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections.first as! AccountDetailsViewModelAccounts
        let account = section.accounts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountCollectionCell", for: indexPath) as! AccountCollectionCell
        cell.configure(for: account)
        
        return cell
    }
}
