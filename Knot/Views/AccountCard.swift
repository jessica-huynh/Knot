//
//  AccountCard.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCard: UIView {

    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var institutionLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("AccountCard", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds    
    }
    
    func draw(with colour: UIColor) {
        let border = CAShapeLayer()
        border.frame = self.contentView.bounds
        border.fillColor = nil
        border.strokeColor = colour.cgColor
        border.lineWidth = 1.0
        border.path = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: 10).cgPath
        self.contentView.layer.addSublayer(border)
    }

    func updateCard(using account: Account) {
        institutionLabel.text = account.institution.name
        accountTypeLabel.text = account.officialName ?? account.name
        
        if let mask = account.mask {
            accountNumberLabel.text = "**** **** **** \(mask)"
        } else {
            accountNumberLabel.text = ""
        }
        
        // TODO
        nameLabel.text = "Jane Doe"
        logoImage.image = UIImage(named: "Logo")
        
        if let hexColour = account.institution.primaryColour {
            draw(with: UIColor(hexString: hexColour))
        } else {
            draw(with: UIColor.lightGray)
        }
        
    }
}
