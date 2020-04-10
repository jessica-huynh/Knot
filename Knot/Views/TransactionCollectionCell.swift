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
    
    func configure(for transaction: Transaction) {
        self.drawBorder()
        
        let absAmount = abs(transaction.amount)
        amountLabel.text = absAmount.toCurrency()!
        descriptionLabel.text = transaction.name
        icon.tintColor = transaction.amount > 0 ? UIColor(hexString: "#7ec290") : UIColor(hexString: "#eb7171")
        icon.image = transaction.amount > 0 ? UIImage(systemName: "plus.circle.fill") : UIImage(systemName: "minus.circle.fill")
    }
}
