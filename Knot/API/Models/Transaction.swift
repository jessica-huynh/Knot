//
//  Transaction.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    let id, accountID, name, date_ISO: String
    let amount: Double
    let pending: Bool
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date_ISO)!
    }

    enum CodingKeys: String, CodingKey {
        case name, amount, pending
        case id = "transaction_id"
        case accountID = "account_id"
        case date_ISO = "date"
    }
}

extension Transaction {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Transaction.self, from: data)
    }
}
