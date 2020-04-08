//
//  UITableViewCell+SelectedBackgroundView.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-08.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    static let lighGrayBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#fafafa")
        return backgroundView
    }()
}
