//
//  TransactionCollectionCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-12.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class TransactionCollectionCell: UICollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    func configure(for transaction: Transaction) {
        self.drawBorder()
        
        let absAmount = abs(transaction.amount)
        amountLabel.text = absAmount.toCurrency()!
        descriptionLabel.text = transaction.name
        accountLabel.text = StorageManager.instance.account(for: transaction.accountID)?.name
    }
}
