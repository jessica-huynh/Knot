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
    @IBOutlet weak var sideBar: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(for transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM d, YYYY"
        dateLabel.text = dateFormatter.string(from: transaction.date)
        
        descriptionLabel.text = transaction.description
        amountLabel.text = "$\(transaction.amount)"
        
        if transaction.description == "Walmart" {
            sideBar.backgroundColor = UIColor.systemRed
        }
    }

}
