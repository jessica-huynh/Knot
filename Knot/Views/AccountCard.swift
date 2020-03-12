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
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = bounds.size.width - 1
        let boxHeight: CGFloat = bounds.size.height - 1
      
        let boxRect = CGRect(x: 0, y: 0, width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor.systemRed.setStroke()
        roundedRect.stroke()
    }


}
