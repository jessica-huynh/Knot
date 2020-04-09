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
        dateFormatter.dateFormat = "EE, MMM dd, YYYY"

        dateLabel.text = dateFormatter.string(from: transaction.date)
        descriptionLabel.text = transaction.name
        amountLabel.text = transaction.amount.toCurrency()!
        amountLabel.textColor = transaction.amount > 0 ? UIColor.systemGreen : UIColor.black
        
    }
}
