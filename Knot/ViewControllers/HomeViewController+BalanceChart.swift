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
        var unfinishedCharts = chartTimePeriods
        plaidManager.getAllTransactions(startDate: startDate.nextDay(), endDate: Date.today) {
            [weak self] transactions in
            guard let self = self else { return }
            
            var daysBalanceChanged: [(date: Date, balance: Double)] = []
            var currentDate = Date.today.nextDay()
            
            for transaction in transactions {
                if transaction.date != currentDate {
                    daysBalanceChanged.append((currentDate.previousDay(), netBalance))
                    currentDate = transaction.date
                    
                    // Try to update chart entires as we go through transactions
                    if unfinishedCharts.contains(where: { transaction.date <= $0.startDate }){
                        let finishedCharts = unfinishedCharts.filter{ transaction.date <= $0.startDate }
                        unfinishedCharts.removeAll{ transaction.date <= $0.startDate }

                        self.updateCharts(charts: finishedCharts, with: daysBalanceChanged)
                    }
                }
                // Backtrack by using each transaction to calculate a past net balance
                netBalance = netBalance + (transaction.accountType == .credit ? transaction.amount : -transaction.amount)
            }
            
            daysBalanceChanged.append((currentDate.previousDay(), netBalance))
            if !unfinishedCharts.isEmpty {
                self.updateCharts(charts: unfinishedCharts, with: daysBalanceChanged)
            }
        }
    }
    
    func updateCharts(charts: [ChartTimePeriod], with daysBalancedChanged: [(date: Date, balance: Double)]) {
        for chart in charts {
            chart.daysBalanceChanged = daysBalancedChanged
        }
    }
    
    // MARK: - Chart Customization
    func customize(balanceChart: LineChartView) {
        balanceChart.xAxis.enabled = false
        balanceChart.leftAxis.enabled = false
        balanceChart.rightAxis.enabled = false
        balanceChart.rightAxis.drawGridLinesEnabled = false
        balanceChart.legend.enabled = false
        balanceChart.highlightPerTapEnabled = false
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
    
    func showIndicators() {
        dateIndicatorLabel.fadeIn()
        balanceIndicatorLabel.fadeIn()
        indicatorPoint.fadeIn()
    }
    
    func hideIndicators() {
        dateIndicatorLabel.fadeOut()
        balanceIndicatorLabel.fadeOut()
        indicatorPoint.fadeOut()
    }
    
    // MARK: - Reload Chart
    func reloadChart() {
        hideIndicators()
        let segmentIndex = chartSegmentedControl.selectedSegmentIndex
        let newChartData = BalanceChartDataSet(entries: chartTimePeriods[segmentIndex].chartEntries)
        balanceChartView.data?.dataSets[0] = newChartData
        
        if !newChartData.isCustomized {
            customize(lineChartDataSet: newChartData)
            newChartData.isCustomized = true
        }
        
        drawChart()
    }
    
    // MARK: - Chart Delegate Functions
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        dateIndicatorLabel.center = CGPoint(x: highlight.xPx + 40, y: -15)
        balanceIndicatorLabel.center = CGPoint(x: highlight.xPx + 40, y: 2)
        indicatorPoint.center = CGPoint(x: highlight.xPx, y: highlight.yPx)
 
        dateIndicatorLabel.text = entry.data as? String
        balanceIndicatorLabel.text = "\(highlight.y.toCurrency()!)"

        showIndicators()
    }
}
