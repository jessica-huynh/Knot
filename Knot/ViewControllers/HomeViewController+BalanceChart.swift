//
//  HomeViewController+BalanceChart.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-16.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import Charts

extension HomeViewController: ChartViewDelegate {
    // MARK: - Initial Chart Setup
    func setupBalanceChart() {
        balanceChartView.delegate = self
        
        indicatorPoint = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        indicatorPoint.image = UIImage(systemName: "circle.fill")
        indicatorPoint.tintColor = UIColor(hexString: "#63BBD7")
        balanceChartView.addSubview(indicatorPoint)
        
        balanceIndicatorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 82, height: 21))
        balanceIndicatorLabel.font = UIFont.systemFont(ofSize: 14)
        balanceIndicatorLabel.textColor = UIColor.systemGray
        balanceIndicatorLabel.adjustsFontSizeToFitWidth = true
        balanceChartView.addSubview(balanceIndicatorLabel)
        
        dateIndicatorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 82, height: 21))
        dateIndicatorLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        dateIndicatorLabel.textColor = UIColor(hexString: "#63BBD7")
        dateIndicatorLabel.adjustsFontSizeToFitWidth = true
        balanceChartView.addSubview(dateIndicatorLabel)
        
        balanceIndicatorLabel.alpha = 0
        dateIndicatorLabel.alpha = 0
        indicatorPoint.alpha = 0
        
        let data = LineChartData()
        data.addDataSet(BalanceChartDataSet())
        balanceChartView.data = data
        
        customize(balanceChart: balanceChartView)
        drawChart()
    }
    
    // MARK: - Chart Entries Helper Functions
    func updateChartEntries() {
        var netBalance = calculateBalance(for: storageManager.cashAccounts) - calculateBalance(for: storageManager.creditAccounts)
        let startDate = Calendar.current.date(byAdding: DateComponents(year: -1), to: Date.today)!
        
        plaidManager.getAllTransactions(startDate: startDate, endDate: Date.today.previousDay()) {
            [weak self] transactions in
            guard let self = self else { return }
            
            var daysBalanceChanged: [(date: Date, balance: Double)] = []
            var currentDate = Date.today
            for transaction in transactions {
                if transaction.date != currentDate {
                    daysBalanceChanged.append((currentDate, netBalance))
                    currentDate = transaction.date
                }
                netBalance = netBalance + (transaction.accountType == .credit ? transaction.amount : -transaction.amount)
            }
            daysBalanceChanged.append((currentDate, netBalance))
            daysBalanceChanged.reverse()
            
            let balanceHistory = self.completeBalanceHistory(from: startDate, with: daysBalanceChanged)

            var chartEntries = [ChartDataEntry]()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE, MMM d, YYYY"
            
            for i in 0..<balanceHistory.count {
                let value = ChartDataEntry(x: Double(i),
                                           y: Double(balanceHistory[i].balance),
                                           data: dateFormatter.string(from: balanceHistory[i].date))
                chartEntries.append(value)
            }
            self.balanceChartEntries = chartEntries
            NotificationCenter.default.post(name: .updatedBalanceChartEntries, object: self)
        }
    }
    
    func completeBalanceHistory(from startDate: Date,
                                with daysBalanceChanged: [(date: Date, balance: Double)])
        -> [(date: Date, balance: Double)] {
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
    
    func generateDataPoints(from startDate: Date, to endDate: Date, with balance: Double) -> [(date: Date, balance: Double)] {
        var dataPoints: [(date: Date, balance: Double)] = []
        var currentDate = startDate

        while currentDate <= endDate {
            dataPoints.append((currentDate, balance))
            currentDate = currentDate.nextDay()
        }
        return dataPoints
    }
    
    // MARK: - Chart Customization
    func customize(balanceChart: LineChartView) {
        balanceChart.xAxis.enabled = false
        balanceChart.leftAxis.enabled = false
        balanceChart.rightAxis.enabled = false
        balanceChart.rightAxis.drawGridLinesEnabled = false
        balanceChart.legend.enabled = false
        balanceChart.setScaleEnabled(false)
    }
    
    func customize(lineChartDataSet: LineChartDataSet) {
        lineChartDataSet.colors = [UIColor(hexString: "#63BBD7")]
        lineChartDataSet.lineWidth = 2.0
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = UIColor.gray
        lineChartDataSet.highlightLineWidth = 2
        lineChartDataSet.highlightLineDashLengths = [2.0]
        
        drawGradient(for: lineChartDataSet, using: UIColor(hexString: "#63BBD7"), bottomColour: UIColor.white)
    }
    
    func drawGradient(for lineChart: LineChartDataSet, using topColour: UIColor, bottomColour: UIColor) {
           let gradientColours = [topColour.cgColor, bottomColour.cgColor]
           let colourLocations: [CGFloat] = [0.7, 0.0]
           let gradient =
               CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: gradientColours as CFArray,
                               locations: colourLocations)!
           lineChart.drawFilledEnabled = true
           lineChart.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
    }
    
    func drawChart() {
        balanceChartView.animate(yAxisDuration: 0.2, easingOption: ChartEasingOption.linear)
        balanceChartView.animate(xAxisDuration: 0.2, easingOption: ChartEasingOption.linear)

        balanceChartView.notifyDataSetChanged()
        highlightCurrentBalance()
    }
    
    func highlightCurrentBalance() {
        let xTouchPoint = balanceChartView.frame.width
        let yTouchPoint = balanceChartView.frame.height
        let highlight = balanceChartView.getHighlightByTouchPoint(CGPoint(x: xTouchPoint, y: yTouchPoint))
        balanceChartView.highlightValue(highlight, callDelegate: true)
    }
    
    // MARK: - Reload Chart
    func reloadChart() {
        dateIndicatorLabel.fadeOut()
        balanceIndicatorLabel.fadeOut()
        indicatorPoint.fadeOut()
        
        let daysInYear = 365
        if let timePeriod = ChartTimePeriod(rawValue: chartSegmentedControl.selectedSegmentIndex) {
            var newChartData: BalanceChartDataSet
            
            switch timePeriod {
            case ChartTimePeriod.week:
                newChartData =
                    BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 7)...]))
            case ChartTimePeriod.month:
                newChartData =
                    BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 30)...]))
            case ChartTimePeriod.threeMonth:
                newChartData =
                    BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 90)...]))
            case ChartTimePeriod.sixMonth:
                newChartData =
                    BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 180)...]))
            case ChartTimePeriod.year:
                newChartData = BalanceChartDataSet(entries: balanceChartEntries)
            }
            
            balanceChartView.data?.dataSets[0] = newChartData
            
            if !newChartData.isCustomized {
                customize(lineChartDataSet: newChartData)
                newChartData.isCustomized = true
            }
            
            drawChart()
        }

    }
    
    // MARK: - Chart Delegate Functions
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        dateIndicatorLabel.center = CGPoint(x: highlight.xPx + 40, y: -15)
        balanceIndicatorLabel.center = CGPoint(x: highlight.xPx + 40, y: 2)
        indicatorPoint.center = CGPoint(x: highlight.xPx, y: highlight.yPx)
 
        dateIndicatorLabel.text = entry.data as? String
        balanceIndicatorLabel.text = "\(highlight.y.toCurrency()!)"

        dateIndicatorLabel.fadeIn()
        balanceIndicatorLabel.fadeIn()
        indicatorPoint.fadeIn()
    }
}
