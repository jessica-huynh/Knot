//
//  BalanceChart.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-04-14.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import Charts

class BalanceChart {
    var timePeriod: TimePeriod
    var isLoading: Bool = false
    var chartEntries: [ChartDataEntry] = []
    var startDate: Date!
    var daysBalanceChanged: [(date: Date, balance: Double)] = [] {
        didSet { updateChartEntries() }
    }
    
    enum TimePeriod: Int, CaseIterable {
        case week, month, threeMonth, sixMonth, year
    }
    
    init(timePeriod: TimePeriod) {
        self.timePeriod = timePeriod
        setStartDate()
    }
    
    func setStartDate() {
        switch timePeriod {
        case .week:
            startDate = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date.today)!
        case .month:
            startDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: Date.today)!
        case .threeMonth:
            startDate = Calendar.current.date(byAdding: DateComponents(month: -3), to: Date.today)!
        case .sixMonth:
            startDate = Calendar.current.date(byAdding: DateComponents(month: -6), to: Date.today)!
        case .year:
            startDate = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date.today)!
        }
    }
    
    func updateChartEntries() {
        var daysBalanceChanged = self.daysBalanceChanged
        daysBalanceChanged.reverse()
        let balanceHistory = completeBalanceHistory(from: startDate, with: daysBalanceChanged)
        
        var chartEntries = [ChartDataEntry]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM d, YYYY"
        
        for i in 0..<balanceHistory.count {
            let value = ChartDataEntry(x: Double(i),
                                       y: Double(balanceHistory[i].balance),
                                       data: dateFormatter.string(from: balanceHistory[i].date))
            chartEntries.append(value)
        }
        self.chartEntries = chartEntries
        NotificationCenter.default.post(name: .updatedBalanceChart, object: self)
    }
    
    func completeBalanceHistory(from startDate: Date,
                                with daysBalanceChanged: [(date: Date, balance: Double)]) -> [(date: Date, balance: Double)] {
        var daysBalanceChanged = daysBalanceChanged
        var balanceHistory: [(date: Date, balance: Double)] = []
        
        while daysBalanceChanged.count != 1 {
            let lastDataPoint = daysBalanceChanged.removeLast()
            let secoundLastDataPoint = daysBalanceChanged.last!
            let partialBalanceHistory = self.generateDataPoints(from: secoundLastDataPoint.date.nextDay(), to: lastDataPoint.date, with: lastDataPoint.balance)
            balanceHistory = partialBalanceHistory + balanceHistory
        }
        
        if daysBalanceChanged.count == 1 && daysBalanceChanged[0].date != startDate {
            let partialBalanceHistory = self.generateDataPoints(from: startDate, to: daysBalanceChanged[0].date, with: daysBalanceChanged[0].balance)
            balanceHistory = partialBalanceHistory + balanceHistory
        } else {
            balanceHistory = [daysBalanceChanged[0]] + balanceHistory
        }
        
        return balanceHistory
    }
    
    func generateDataPoints(from startDate: Date,
                            to endDate: Date, with balance: Double) -> [(date: Date, balance: Double)] {
        var dataPoints: [(date: Date, balance: Double)] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dataPoints.append((currentDate, balance))
            currentDate = currentDate.nextDay()
        }
        return dataPoints
    }
}
