//
//  Double+Currency.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

extension Double {
    /// Tries to convert its value to a string in (local) currency format.
    func toCurrency() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let string = formatter.string(from: self as NSNumber) {
            return string
        }
        return nil
    }
}
