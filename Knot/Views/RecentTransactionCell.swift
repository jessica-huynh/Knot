//
//  TransactionCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class RecentTransactionCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    func configure(using transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd, YYYY"

        dateLabel.text = dateFormatter.string(from: transaction.date)
        descriptionLabel.text = transaction.name
        amountLabel.text = transaction.amount.toCurrency()!
        amountLabel.textColor = transaction.amount > 0 ? UIColor(hexString: "#6bb07d") : UIColor(hexString: "#d93f3f")
        accountLabel.text = StorageManager.instance.account(for: transaction.accountID)?.name
    }
}
