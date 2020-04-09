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
    func sublayer(with name: String) -> CALayer? {
        guard let sublayers = contentView.layer.sublayers else { return nil }
        for sublayer in sublayers {
            if sublayer.name == name { return sublayer }
        }
        return nil
    }
    
    func drawBorder(with cornerRadius: CGFloat = 10.0, width: CGFloat = 1.0, colour: CGColor = UIColor.lightGray.cgColor, lineDashPattern: [NSNumber]? = nil) {
        let layerName = "borderLayer"
        
        // First check if border layer has already been drawn
        if let _ = sublayer(with: layerName) { return }
        
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        let borderLayer = CAShapeLayer()
        borderLayer.name = layerName
        borderLayer.frame = contentView.bounds
        borderLayer.fillColor = nil
        borderLayer.strokeColor = colour
        borderLayer.lineWidth = width
        borderLayer.lineDashPattern = lineDashPattern
        borderLayer.path = UIBezierPath(roundedRect: contentView.bounds,
                                        cornerRadius: cornerRadius).cgPath
        contentView.layer.addSublayer(borderLayer)
    }
}
