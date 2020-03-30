//
//  UICollectionViewCell+DrawBorder.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-27.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    func drawBorder(with cornerRadius: CGFloat = 10.0, width: CGFloat = 1.0, colour: CGColor = UIColor.lightGray.cgColor, lineDashPattern: [NSNumber]? = nil) {
        self.contentView.layer.cornerRadius = cornerRadius
        self.contentView.layer.masksToBounds = true
        
        let border = CAShapeLayer()
        border.frame = self.contentView.bounds
        border.fillColor = nil
        border.strokeColor = colour
        border.lineWidth = width
        border.lineDashPattern = lineDashPattern
        border.path = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: cornerRadius).cgPath
        self.contentView.layer.addSublayer(border)
    }
}
