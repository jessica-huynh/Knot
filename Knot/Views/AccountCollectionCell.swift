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
    
    func configure(for account: Account) {
        self.drawBorder()
        
        institutionLabel.text = account.institution.name
        nameLabel.text = account.name
        balanceLabel.text = account.balance.current.toCurrency()!
        
        if let hexColour = account.institution.primaryColour {
            sidebar.backgroundColor = UIColor(hexString: hexColour)
        } else {
            sidebar.backgroundColor = UIColor.clear
        }
        
        if account.type == .credit {
            detailsLabel.text = "Limit: \(account.balance.limit!.toCurrency()!)"
            return
        }
        // If account type is cash:
        var holds: Double = 0
        if let availableBalance = account.balance.available {
            holds = account.balance.current - availableBalance
        }
        detailsLabel.text = "Holds: \(holds.toCurrency()!)"
    }
}
