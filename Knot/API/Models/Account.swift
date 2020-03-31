//
//  Account.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Account: Codable, CustomStringConvertible, Equatable {
    let id, name, subtype: String
    let type: AccountType
    let mask, officialName: String?
    let balance: Balance
    
    var dateAdded: Date = Date()
    var institution: Institution { return StorageManager.instance.institutionsByID[self.id]! }
    var accessToken: String { return StorageManager.instance.accessToken(for: self.id)! }
    
    enum CodingKeys: String, CodingKey {
        case name, mask, type, subtype
        case id = "account_id"
        case officialName = "official_name"
        case balance = "balances"
    }
    
    enum AccountType: String, Codable, Equatable {
        case investment, credit, depository, loan, other
    }
    
    var description: String {
        return "Account ID: \(id), name: \(name), type: \(type), balance: \(balance.current)"
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Account {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Account.self, from: data)
    }
}
