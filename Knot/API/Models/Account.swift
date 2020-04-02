//
//  Account.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Account: Codable, CustomStringConvertible, Equatable {
    let id, name: String
    let type: AccountType
    let mask, officialName: String?
    let balance: Balance
    
    var dateAdded: Date = Date()
    var institution: Institution { return StorageManager.instance.institutionsByID[self.id]! }
    var accessToken: String { return StorageManager.instance.accessToken(for: self.id)! }
    
    enum CodingKeys: String, CodingKey {
        case name, mask, type
        case id = "account_id"
        case officialName = "official_name"
        case balance = "balances"
    }
    
    enum AccountType: String, Codable, Equatable {
        case investment, credit, depository, loan, other
    }
    
    init(id: String, name: String, type: AccountType, mask: String?, officialName: String?, balance: Balance) {
        self.id = id
        self.name = name
        self.type = type
        self.mask = mask
        self.officialName = officialName
        self.balance = balance
    }
    
    var description: String {
        return "Account ID: \(id), name: \(name), type: \(type), balance: \(balance.current)"
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Account {
    convenience init(data: Data) throws {
        let account = try JSONDecoder().decode(Account.self, from: data)
        self.init(id: account.id,
                  name: account.name,
                  type: account.type,
                  mask: account.mask,
                  officialName: account.officialName,
                  balance: account.balance)
    }
}
