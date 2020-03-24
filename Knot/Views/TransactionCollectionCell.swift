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
        amountLabel.text = transaction.amount.toCurrency()!
        descriptionLabel.text = transaction.name
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.masksToBounds = true
    }
}
