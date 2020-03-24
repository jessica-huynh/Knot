//
//  ProfileViewModel.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewModelSection {
    var type: ProfileViewModel.SectionType { get }
    var title: String { get }
    var rowCount: Int { get }
}

class ProfileViewModel: NSObject {
    let storageManager = StorageManager.instance
    
    enum SectionType {
        case accounts
        case eraseData
    }
    
    var sections = [ProfileViewModelSection]()
    
    override init() {
        super.init()
        
        let accounts = storageManager.cashAccounts + storageManager.creditAccounts

        sections.append(ProfileViewModelAccounts(accounts: accounts))
        sections.append(ProfileViewModelEraseData())
    }
}

// MARK: - Table View Data Source
extension ProfileViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        
        switch section.type {
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountNumberCell", for: indexPath)
            let section = section as! ProfileViewModelAccounts
            let account = section.accounts[indexPath.row]
            
            cell.textLabel?.text = (storageManager.institutions[account.id]?.name)
            
            if let mask = account.mask {
                cell.textLabel?.text! += " (\(mask))"
            }
            
            cell.detailTextLabel?.text = section.accounts[indexPath.row].name
            return cell
            
        case .eraseData:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EraseDataCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - View Model Data
class ProfileViewModelAccounts: ProfileViewModelSection {
    var accounts: [Account]
    
    var type: ProfileViewModel.SectionType {
        return .accounts
    }
    
    var title: String {
        return "Accounts"
    }
    
    var rowCount: Int {
        return accounts.count
    }
    
    init(accounts: [Account]) {
        self.accounts = accounts
    }
}

class ProfileViewModelEraseData: ProfileViewModelSection {
    var type: ProfileViewModel.SectionType {
        return .eraseData
    }
    
    var title: String {
        return " "
    }
    
    var rowCount: Int {
        return 1
    }
}
