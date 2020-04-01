//
//  UIImage+Base64Convert.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-01.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static func base64Convert(base64String: String?) -> UIImage {
        if base64String == nil {
            return UIImage(color: UIColor.clear, size: CGSize(width: 50, height: 50))
        }
        let dataDecoded : Data = Data(base64Encoded: base64String!, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage!
    }
}
