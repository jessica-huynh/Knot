//
//  Transaction.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Transaction: Codable, CustomStringConvertible {
    let id, accountID, name, _date: String
    let _amount: Double
    let pending: Bool
    var amount: Double { return _amount * -1 }
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: _date)!
    }

    enum CodingKeys: String, CodingKey {
        case name, pending
        case id = "transaction_id"
        case accountID = "account_id"
        case _date = "date"
        case _amount = "amount"
    }
    
    var description: String {
        return "Transaction ID: \(id), name: \(name), amount: \(amount.toCurrency()!), date: \(_date)\n"
    }
}

extension Transaction {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Transaction.self, from: data)
    }
}

func > (lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.date > rhs.date
}
