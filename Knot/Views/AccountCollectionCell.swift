//
//  AccountCollectionCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-27.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCollectionCell: UICollectionViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var logo: UIImageView!
    
    func configure(for account: Account) {
        self.drawBorder()
        
        institutionLabel.text = StorageManager.instance.institutionsByID[account.id]?.name
        nameLabel.text = account.name
        balanceLabel.text = account.balance.current.toCurrency()!
        
        switch account.type {
        case .credit:
            detailsLabel.text = "Limit: \(account.balance.limit!.toCurrency()!)"
        case .depository:
            var holds: Double = 0
            if let availableBalance = account.balance.available {
                holds = account.balance.current - availableBalance
            }
            detailsLabel.text = "Holds: \(holds.toCurrency()!)"
        default:
            break
        }
    }
}
