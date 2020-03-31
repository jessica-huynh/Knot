//
//  AccountFilterItem.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-31.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct AccountFilterItem: Equatable {
    let account: Account
    var isChecked: Bool
    
    func with(account: Account? = nil, isChecked: Bool? = nil) -> AccountFilterItem {
         return AccountFilterItem(
            account: account ?? self.account,
            isChecked: isChecked ?? self.isChecked)
     }
    
    static func == (lhs: AccountFilterItem, rhs: AccountFilterItem) -> Bool {
        return (lhs.account == rhs.account) && (lhs.isChecked == rhs.isChecked)
    }
}
