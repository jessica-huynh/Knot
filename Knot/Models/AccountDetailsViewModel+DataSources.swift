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
extension AccountDetailsViewModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = sections[section].type
        
        if sectionType == .accounts { return 1 }
        if sectionType == .postedTransactions && isLoading { return 2 }
        if sectionType == .postedTransactions { return sections[section].rowCount + 2}
        if sections[section].rowCount == 0 { return 1 }
        
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            cell.accountCollectionView.dataSource = self
            cell.accountCollectionView.delegate = self
            
            return cell
            
        case .postedTransactions:
            let section = section as! PostedTransactionsSection
            if isLoading && indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell") as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
            
            if section.filteredTransactions.isEmpty && indexPath.row == 1 {
                return tableView.dequeueReusableCell(withIdentifier: "NoTransactionsFoundCell")!
            }
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsHeaderCell") as! TransactionsHeaderCell
                cell.delegate = self
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width);
                return cell
            }
            
            if indexPath.row == section.filteredTransactions.count + 1 {
                return tableView.dequeueReusableCell(withIdentifier: "ReachedEndCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.configure(using: section.filteredTransactions[indexPath.row - 1])
            return cell
            
        case .pendingTransactions:
            let section = section as! PendingTransactionsSection
            if section.filteredTransactions.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: "NoPendingTransactionsCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as! TransactionCell
            cell.configure(using: section.filteredTransactions[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - Collection View Data Source
extension AccountDetailsViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.first!.rowCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == sections.first!.rowCount {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddAccountCollectionCell", for: indexPath)
            cell.drawBorder(lineDashPattern: [2, 2])
            return cell
        }
        let section = sections.first as! AccountsSection
        let account = section.accounts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountCollectionCell", for: indexPath) as! AccountCollectionCell
        cell.configure(for: account)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == sections.first!.rowCount {
            NotificationCenter.default.post(name: .addAccountTapped, object: self)
        }
    }
}
