//
//  AccountDetailsViewModel+FilterTransactions.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

extension AccountDetailsViewModel: FilterTransactionsCellDelegate {
    func filterTransactionsCell(_: FilterTransactionsCell, didUpdateTimeFrame timeFrame: DateInterval) {
        updatePostedTransactions(startDate: timeFrame.start, endDate: timeFrame.end)
    }
}
