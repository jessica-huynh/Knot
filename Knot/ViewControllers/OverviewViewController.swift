//
//  OverviewViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-09.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import Charts

class OverviewViewController: UITableViewController {
    
    let maxTransactionsDisplayed = 6
    let lastTransactionIndex = 6
    var transactions: [Transaction]!
    
    // MARK: - Outlets
    @IBOutlet weak var netBalanceLabel: UILabel!
    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var creditCardsBalanceLabel: UILabel!
    @IBOutlet weak var investmentsBalanceLabel: UILabel!
    @IBOutlet weak var transactionCollectionView: UICollectionView!
    @IBOutlet weak var balanceChartView: LineChartView!
    @IBOutlet weak var balanceIndicatorLabel: UILabel!
    @IBOutlet weak var timeIndicatorLabel: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTransactionCollectionVew()
        setupBalanceChart()
        updateLabels()
        
        let transaction1 = Transaction(description: "Uber", date: Date(), amount: 12.45)
        let transaction2 = Transaction(description: "Walmart", date: Date(), amount: 38.12)
        let transaction3 = Transaction(description: "Transfer", date: Date(), amount: -50.00)
        let transaction4 = Transaction(description: "Transfer", date: Date(), amount: -50.00)
        let transaction5 = Transaction(description: "Transfer", date: Date(), amount: -50.00)
        let transaction6 = Transaction(description: "Transfer", date: Date(), amount: -50.00)
        transactions = [transaction1, transaction2, transaction3, transaction4, transaction5, transaction6, transaction1]
    }
    
    // MARK: - Actions
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    /*
    @IBSegueAction func addSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: BalanceLineChartView(data: [8,30,54,32,12,37,7,63,43]))
    }
 */

    // MARK: - Helper Functions
    func setupTransactionCollectionVew() {
        transactionCollectionView.dataSource = self
        transactionCollectionView.delegate = self
        transactionCollectionView.showsHorizontalScrollIndicator = false
        transactionCollectionView.register(
            UINib(nibName: "TransactionCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "TransactionCollectionCell")
    }
    
    func setupBalanceChart() {
        balanceChartView.delegate = self
        
        let balance = [32050, 500000, 500000, 250000, 250000, 500000, 500000, 400000, 400000, 1500000, 1500000, 1500000, 1500000]
        
        var lineChartEntry = [ChartDataEntry]()

        for i in 0..<balance.count {
            let value = ChartDataEntry(x: Double(i), y: Double(balance[i]), data: "Mon")
            lineChartEntry.append(value)
        }
        
        let balanceData = LineChartDataSet(entries: lineChartEntry)
        let data = LineChartData()
        data.addDataSet(balanceData)
        balanceChartView.data = data
        
        customizeBalanceChart()
    }
    
    func customizeBalanceChart() {
        let balanceData = balanceChartView.data!.dataSets[0] as! LineChartDataSet
        
        balanceData.colors = [UIColor.systemBlue]
        balanceData.lineWidth = 2.0
        balanceData.drawCirclesEnabled = false
        balanceData.drawValuesEnabled = false
        
        balanceData.drawHorizontalHighlightIndicatorEnabled = false
        balanceData.highlightColor = UIColor.gray
        balanceData.highlightLineDashLengths = [2.0]
        
        balanceChartView.xAxis.enabled = false
        balanceChartView.leftAxis.enabled = false
        balanceChartView.rightAxis.drawGridLinesEnabled = false
        balanceChartView.legend.enabled = false
        balanceChartView.animate(yAxisDuration: 0.8, easingOption: ChartEasingOption.linear)
        balanceChartView.animate(xAxisDuration: 0.8, easingOption: ChartEasingOption.linear)
        balanceChartView.setScaleEnabled(false)
        balanceChartView.highlightPerTapEnabled = false
        
        drawGradient(for: balanceData, using: UIColor.systemBlue, bottomColour: UIColor.white)
        balanceIndicatorLabel.alpha = 0
        timeIndicatorLabel.alpha = 0
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
    
    func updateLabels() {
        netBalanceLabel.text = "$12,735.58"
        cashBalanceLabel.text = "$15,379.00"
        creditCardsBalanceLabel.text = "3129.67"
        investmentsBalanceLabel.text = "---"
    }
    
    /*
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AccountDetailsViewController {
            controller.navTitle = segue.identifier
            
            if segue.identifier == "All Transactions" {
                controller.showAccounts = false
            }
        }
    }
}

// MARK: - Line Chart View Extension
extension OverviewViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let firstEntry = chartView.data?.dataSets[0].entryForIndex(0)

        if entry == firstEntry {
            timeIndicatorLabel.center = CGPoint(x: highlight.xPx + 10, y: -18)
            balanceIndicatorLabel.center = CGPoint(x: highlight.xPx + 10, y: -2)
        } else {
            timeIndicatorLabel.center = CGPoint(x: highlight.xPx, y: -18)
            balanceIndicatorLabel.center = CGPoint(x: highlight.xPx, y: -2)
        }
 
        timeIndicatorLabel.text = entry.data as? String
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let balance = formatter.string(from: highlight.y as NSNumber) {
            balanceIndicatorLabel.text = "\(balance)"
        }

        timeIndicatorLabel.fadeIn()
        balanceIndicatorLabel.fadeIn()
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        timeIndicatorLabel.fadeOut()
        balanceIndicatorLabel.fadeOut()
        chartView.highlightValue(nil)
    }
}


// MARK: - Collection View Extension
extension OverviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (transactions.count > maxTransactionsDisplayed ?
                maxTransactionsDisplayed + 1 : maxTransactionsDisplayed)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == lastTransactionIndex {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewMoreTransactionsCell", for: indexPath)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionCollectionCell", for: indexPath) as! TransactionCollectionCell
        cell.configure(for: transactions[indexPath.item])
        return cell
    }
    
}
