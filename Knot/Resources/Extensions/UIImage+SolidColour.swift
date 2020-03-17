//
//  UIImage+SolidColour.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-17.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let context = UIGraphicsGetCurrentContext()!
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
}
