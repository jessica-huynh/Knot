//
//  Transaction.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Transaction: Codable, CustomStringConvertible {
    let id, accountID, name, _date: String
    let _amount: Double
    let pending: Bool
    
    var amount: Double {
        let accountType = StorageManager.instance.account(for: accountID)?.type
        return (accountType == Account.AccountType.credit) ? _amount : _amount * -1
    }
    var date: Date {
        return PlaidAPI.dateFormatter.date(from: _date)!
    }

    enum CodingKeys: String, CodingKey {
        case name, pending
        case id = "transaction_id"
        case accountID = "account_id"
        case _date = "date"
        case _amount = "amount"
    }
    
    init(id: String, accountID: String, name: String, _date: String, _amount: Double,
         pending: Bool) {
        self.id = id
        self.accountID = accountID
        self.name = name
        self._date = _date
        self._amount = _amount
        self.pending = pending
    }
    
    var description: String {
        return "Transaction ID: \(id), name: \(name), amount: \(amount.toCurrency()!), date: \(_date)\n"
    }
}

extension Transaction {
    convenience init(data: Data) throws {
        let transaction = try JSONDecoder().decode(Transaction.self, from: data)
        self.init(id: transaction.id,
                  accountID: transaction.accountID,
                  name: transaction.name,
                  _date: transaction._date,
                  _amount: transaction._amount,
                  pending: transaction.pending)
    }
}

func > (lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.date > rhs.date
}
