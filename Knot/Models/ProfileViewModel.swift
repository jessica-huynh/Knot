//
//  ProfileViewModel.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-10.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

// Temp account data model
struct Account {
    let institution: String
    let accountNumber: String
}


protocol ProfileViewModelSection {
    var type: ProfileViewModel.SectionType { get }
    var title: String { get }
    var rowCount: Int { get }
}

class ProfileViewModel: NSObject {
    enum SectionType {
        case accounts
        case eraseData
    }
    
    var sections = [ProfileViewModelSection]()
    
    override init() {
        super.init()

        // Fake account data
        let account1 = Account(institution: "Scotiabank", accountNumber: "**** **** 4316")
        let account2 = Account(institution: "Tangerine", accountNumber: "**** **** 8625")
        let account3 = Account(institution: "Simplii", accountNumber: "**** **** 2906")
        let accounts = [account1, account2, account3]
        
        sections.append(Accounts(accounts: accounts))
        sections.append(EraseDataButton())
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
            let section = section as! Accounts
            cell.textLabel?.text = section.accounts[indexPath.row].institution
            cell.detailTextLabel?.text = section.accounts[indexPath.row].accountNumber
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
class Accounts: ProfileViewModelSection {
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

class EraseDataButton: ProfileViewModelSection {
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
