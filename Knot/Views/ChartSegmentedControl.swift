//
//  ChartSegmentedControl.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-16.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

class ChartSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        let tintColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        setTitleTextAttributes([.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)], for: .normal)
 
        setTitleTextAttributes([.foregroundColor: tintColor!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle], for: .selected)
    }
}
