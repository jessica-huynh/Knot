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
    
    var spinnerView: UIView!
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var chartSpinnerView: UIView!
    var chartSpinnerViewIsShown: Bool = false
    
    var balanceIndicatorLabel: UILabel!
    var dateIndicatorLabel: UILabel!
    var indicatorPoint: UIImageView!
    
    var recentTransactions: [Transaction] = []
    var balanceCharts: [BalanceChart] = []
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedBalanceChart(_:)), name: .updatedBalanceChart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessfulLinking(_:)), name: .successfulLinking, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNoValidAccountsAdded(_:)), name: .noValidAccountsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBeganFetchUpdates), name: .beganFetchUpdates, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        spinnerView = createSpinnerView()
        let chartCenter = CGPoint(x: balanceChartView.bounds.width/2 + 48, y: balanceChartView.bounds.height/2)
        chartSpinnerView = balanceChartView.createSpinnerView(at: chartCenter)
        startSpinner()
        setupBalanceChart()
        setupTransactionCollectionVew()
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentPlaidLink()
    }
    
    @IBAction func chartSegmentChanged(_ sender: UISegmentedControl) {
        let selectedIndex = chartSegmentedControl.selectedSegmentIndex
        let selectedChart = balanceCharts[selectedIndex]
        
        if !chartSpinnerViewIsShown && selectedChart.isLoading {
            startChartSpinner()
        } else if chartSpinnerViewIsShown && !selectedChart.isLoading {
            stopChartSpinner()
        }
        reloadChart()
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        isRefreshing = true
        storageManager.fetchAccountUpdates()
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
            balanceLabel.text = "---"
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
    
    // MARK: Spinner Helpers
    func startSpinner() {
        showSpinner(spinnerView: spinnerView)
        isLoading = true
    }
    
    func stopSpinner() {
        removeSpinner(spinnerView: spinnerView)
        isLoading = false
    }
    
    func startChartSpinner() {
        hideIndicators()
        balanceChartView.showSpinner(spinnerView: chartSpinnerView)
        chartSpinnerViewIsShown = true
    }
    
    func stopChartSpinner() {
        balanceChartView.removeSpinner(spinnerView: chartSpinnerView)
        chartSpinnerViewIsShown = false
        showIndicators()
    }
    
    // MARK: Prepare for segue
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
    @objc func onSuccessfulLinking(_ notification:Notification) {
        startSpinner()
    }
    
    @objc func onNoValidAccountsAdded(_ notification:Notification) {
        stopSpinner()
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        startChartSpinner()
        for chart in balanceCharts {
            chart.isLoading = true
        }
        
        updateBalanceCharts()
        updateLabels()
        updateRecentTransactions()
        
        // Remove refresh spinner/full screen view spinner at this point
        if isLoading {
            stopSpinner()
        } else if isRefreshing {
            refreshControl?.endRefreshing()
            isRefreshing = false
        }
    }
    
    @objc func onUpdatedBalanceChart(_ notification:Notification) {
        guard let sender = notification.object as? BalanceChart else { return }
        sender.isLoading = false
        
        let selectedIndex = chartSegmentedControl.selectedSegmentIndex
        let selectedChart = balanceCharts[selectedIndex]
        
        if sender === selectedChart {
            stopChartSpinner()
            reloadChart()
        }
    }
    
    @objc func onBeganFetchUpdates() {
        isLoading = true
        showSpinner(spinnerView: spinnerView)
        
        // Dismiss all view controllers
        navigationController?.popToRootViewController(animated: false)
        
        for scene in UIApplication.shared.connectedScenes {
            (scene as! UIWindowScene).windows.forEach {
                if $0.isKeyWindow {
                    $0.rootViewController?.dismiss(animated: false, completion: nil)
                    return
                }
            }
        }
    }
}
