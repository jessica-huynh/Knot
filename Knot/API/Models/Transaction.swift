//
//  Transaction.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    let id, accountID, name, date: String
    let amount: Double
    let pending: Bool

    enum CodingKeys: String, CodingKey {
        case name, date, amount, pending
        case id = "transaction_id"
        case accountID = "account_id"
    }
}

extension Transaction {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Transaction.self, from: data)
    }
}
