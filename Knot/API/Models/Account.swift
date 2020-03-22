//
//  Account.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Account: Codable, CustomStringConvertible {
    let id, name, subtype: String
    let type: AccountType
    let mask, officialName: String?
    let balance: Balance
    
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
}

extension Account {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Account.self, from: data)
    }
}
