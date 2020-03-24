//
//  TransactionCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func configure(using transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: transaction.date)
        dateFormatter.dateFormat = "EE, MMM dd, YYYY"

        dateLabel.text = dateFormatter.string(from: date!)
        descriptionLabel.text = transaction.name
        amountLabel.text = transaction.amount.toCurrency()!
    }
}
