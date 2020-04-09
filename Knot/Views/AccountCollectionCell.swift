//
//  AccountCollectionCell.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-27.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var institutionLabel: UILabel!
    
    func configure(for account: Account) {
        drawCard(with: UIColor(hexString: account.institution.colour).darken(by: 10))
        nameLabel.text = account.name
        balanceLabel.text = account.balance.current.toCurrency()!
        institutionLabel.text = account.institution.name.uppercased()
    }
    
    func drawCard(with colour: UIColor) {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        let layerName = "cardLayer"
        let cardLayer = CAShapeLayer()
        cardLayer.name = layerName
        cardLayer.frame = self.contentView.bounds
        cardLayer.fillColor = colour.cgColor
        cardLayer.strokeColor = colour.cgColor
        cardLayer.lineWidth = 1.0
        cardLayer.path = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 10).cgPath
        
        if let sublayer = sublayer(with: layerName) {
            contentView.layer.replaceSublayer(sublayer, with: cardLayer)
        } else {
            contentView.layer.insertSublayer(cardLayer, at: 0)
        }
    }
}
