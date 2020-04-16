//
//  Transaction.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Transaction: Codable, CustomStringConvertible {
    let id, accountID, name: String
    /// The date returned by Plaid in the format YYYY-MM-DD
    let _date: String
    /**
     The amount of the transaction returned by Plaid.
     - Note: Positive means money moves out of the account. Negative means money moves into the account.
     */
    let _amount: Double
    let pending: Bool
    var accountType: Account.AccountType {
        return StorageManager.instance.account(for: accountID)!.type
    }
    /**
    The amount of the transaction relative to the type of account.
    - Spending means a positive amount in a credit account but negative in a depository (i.e. cash) account.
    - Money moving into an account means a negative amount in a credit account but positive in a cash account.
    */
    var amount: Double {
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
