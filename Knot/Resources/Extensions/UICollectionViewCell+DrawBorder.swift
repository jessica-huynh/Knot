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
    func drawBorder(with cornerRadius: CGFloat = 10.0, width: CGFloat = 1.0, colour: CGColor = UIColor.lightGray.cgColor) {
        self.contentView.layer.cornerRadius = cornerRadius
        self.contentView.layer.borderWidth = width
        self.contentView.layer.borderColor = colour
        self.contentView.layer.masksToBounds = true
    }
}
