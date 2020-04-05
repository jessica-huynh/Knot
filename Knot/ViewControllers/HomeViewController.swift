//
//  HomeViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-09.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import Charts
import Moya

class HomeViewController: UITableViewController {
    let plaidManager = PlaidManager.instance
    let storageManager = StorageManager.instance
    
    var balanceIndicatorLabel: UILabel!
    var timeIndicatorLabel: UILabel!
    
    var recentTransactions: [Transaction] = []
    
    var balanceChartEntries: [ChartDataEntry] = []
    var balanceChartData_1w = BalanceChartDataSet()
    var balanceChartData_1m = BalanceChartDataSet()
    var balanceChartData_3m = BalanceChartDataSet()
    var balanceChartData_6m = BalanceChartDataSet()
    var balanceChartData_1y = BalanceChartDataSet()
    
    enum ChartTimePeriod: Int {
        case week
        case month
        case threeMonth
        case sixMonth
        case year
    }
    
    // MARK: - Outlets
    @IBOutlet weak var netBalanceLabel: UILabel!
    @IBOutlet weak var cashCell: UITableViewCell!
    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var creditCardsCell: UITableViewCell!
    @IBOutlet weak var creditCardsBalanceLabel: UILabel!
    @IBOutlet weak var transactionCollectionView: UICollectionView!
    @IBOutlet weak var noTransactionsFoundLabel: UILabel!
    @IBOutlet weak var balanceChartView: LineChartView!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBalanceChartEntries(_:)), name: .updatedBalanceChartEntries, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupBalanceChart()
        updateLabels()
        setupTransactionCollectionVew()
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentPlaidLink()
    }
    
    @IBAction func chartSegmentChanged(_ sender: UISegmentedControl) {
        reloadChart()
    }
    
    // MARK: - Helper Functions
    func updateLabels() {
        let cashBalance = calculateBalance(for: storageManager.cashAccounts)
        let creditBalance = calculateBalance(for: storageManager.creditAccounts)
        let netBalance = cashBalance - creditBalance
        
        netBalanceLabel.text = netBalance.toCurrency()!
        cashBalanceLabel.text = cashBalance.toCurrency()!
        creditCardsBalanceLabel.text = creditBalance.toCurrency()!
        
        resetBalanceCell(for: .depository)
        resetBalanceCell(for: .credit)
    }
    
    func calculateBalance(for accounts: [Account]) -> Double {
        var balance = 0.0
        for account in accounts {
            balance += account.balance.current
        }
        
        return balance
    }
    
    func resetBalanceCell(for accountType: Account.AccountType) {
        var accounts: [Account]
        var balanceLabel: UILabel!
        var balanceCell: UITableViewCell!

        if accountType == .depository {
            accounts = storageManager.cashAccounts
            balanceLabel = cashBalanceLabel
            balanceCell = cashCell
        } else {
            accounts = storageManager.creditAccounts
            balanceLabel = creditCardsBalanceLabel
            balanceCell = creditCardsCell
        }
        
        if accounts.isEmpty {
            balanceLabel.text = "---\t"
            balanceCell.accessoryType = .none
            balanceCell.contentView.alpha = 0.3
        } else {
            balanceCell.accessoryType = .disclosureIndicator
            balanceCell.contentView.alpha = 1
        }
    }
    
    func updateRecentTransactions() {
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -30), to: Date.today)!
        
        plaidManager.getAllTransactions(startDate: startDate, endDate: Date.today) {
            [weak self] transactions in
            guard let self = self else { return }
            
            self.recentTransactions = transactions
            self.noTransactionsFoundLabel.isHidden = self.recentTransactions.isEmpty ? false : true
            self.transactionCollectionView.reloadData()
        }
    }
    
     // MARK: - Table View Delegates
     override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == IndexPath(row: 0, section: 1) && storageManager.cashAccounts.isEmpty {
            return indexPath // TOOD Change back to nil
        } else if indexPath == IndexPath(row: 1, section: 1) && storageManager.creditAccounts.isEmpty {
            return indexPath // TOOD Change back to nil
        }
        return indexPath
     }
     
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AccountDetailsViewController {
            controller.navTitle = segue.identifier
            
            if segue.identifier == "Cash" {
                controller.accountType = .depository
            } else if segue.identifier == "Credit Cards" {
                controller.accountType = .credit
            }
        }
        
        if segue.identifier == "Recent Transactions" {
            let controller = segue.destination as! RecentTransactionsViewController
            controller.recentTransactions = recentTransactions
        }
    }
    
    // MARK: - Notification Selectors
    @objc func onUpdatedAccounts(_ notification:Notification) {
        updateLabels()
        updateRecentTransactions()
    }
    
    @objc func onUpdatedBalanceChartEntries(_ notification:Notification) {
        let daysInYear = 365
        balanceChartData_1w =
            BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 7)...]))
        balanceChartData_1m =
            BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 30)...]))
        balanceChartData_3m =
            BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 90)...]))
        balanceChartData_6m =
            BalanceChartDataSet(entries: Array(balanceChartEntries[(daysInYear - 180)...]))
        balanceChartData_1y =
            BalanceChartDataSet(entries: balanceChartEntries)
        
        reloadChart()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let updatedAccounts = Notification.Name("updatedAccount")
    static let updatedBalanceChartEntries = Notification.Name("updatedBalanceHistory")
}
