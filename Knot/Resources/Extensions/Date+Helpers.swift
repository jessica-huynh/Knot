//
//  Date+Helpers.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

extension Date {
    static let today: Date = Date()
    
    func nextDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1), to: self)!
    }
    
    func previousDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: -1), to: self)!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
