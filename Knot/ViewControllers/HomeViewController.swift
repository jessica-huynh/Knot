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
    let provider = MoyaProvider<PlaidAPI>()
    
    var balanceIndicatorLabel: UILabel!
    var timeIndicatorLabel: UILabel!
    
    lazy var balanceChartData_1w = balanceChartData(for: ChartTimePeriod.week)
    lazy var balanceChartData_1m = balanceChartData(for: ChartTimePeriod.month)
    lazy var balanceChartData_3m = balanceChartData(for: ChartTimePeriod.threeMonth)
    lazy var balanceChartData_6m = balanceChartData(for: ChartTimePeriod.sixMonth)
    lazy var balanceChartData_1y = balanceChartData(for: ChartTimePeriod.year)
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLinkAccount(_:)), name: .didLinkAccount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidUpdateTransactions(_:)), name: .didUpdateTransactions, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCashAccountsIsEmptyChanged(_:)), name: .cashIsEmptyChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCreditCardAccountIsEmptyChanged(_:)), name: .creditCardsIsEmptyChanged, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupBalanceChart()
        updateLabels()
        resetBalanceCell(for: .depository)
        resetBalanceCell(for: .credit)
        setupTransactionCollectionVew()
    }
    
    // MARK: - Actions
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentPlaidLink()
    }
    
    // MARK: - Helper Functions
    func updateLabels() {
        let cashBalance = calculateBalance(for: storageManager.cashAccounts)
        let creditBalance = calculateBalance(for: storageManager.creditAccounts)
        let netBalance = cashBalance - creditBalance
        
        netBalanceLabel.text = netBalance.toCurrency()!
        cashBalanceLabel.text = cashBalance.toCurrency()!
        creditCardsBalanceLabel.text = creditBalance.toCurrency()!
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
    
     // MARK: - Table View Delegates
     override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == IndexPath(row: 0, section: 1) && storageManager.cashAccounts.isEmpty {
            return nil
        } else if indexPath == IndexPath(row: 1, section: 1) && storageManager.creditAccounts.isEmpty {
            return nil
        }
        return indexPath
     }
     
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AccountDetailsViewController {
            controller.navTitle = segue.identifier
            
            if segue.identifier == "Cash" {
                controller.viewModel = AccountDetailsViewModel(for: .depository)
            } else if segue.identifier == "Credit Cards" {
                controller.viewModel = AccountDetailsViewModel(for: .credit)
            } else if segue.identifier == "All Transactions" {
                // Not going to show any accounts, so account type is `nil`:
                controller.viewModel = AccountDetailsViewModel(for: nil)
                // Do not give option to add account from All Transactions scene:
                controller.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    // MARK: - Notification Selectors
    @objc func onDidLinkAccount(_ notification:Notification) {
        updateLabels()
    }
    
    @objc func onDidUpdateTransactions(_ notification:Notification) {
        noTransactionsFoundLabel.isHidden =
            storageManager.allTransactions.isEmpty ? false : true
        transactionCollectionView.reloadData()
    }
    
    @objc func onCashAccountsIsEmptyChanged(_ notification:Notification) {
        resetBalanceCell(for: .depository)
    }
    
    @objc func onCreditCardAccountIsEmptyChanged(_ notification:Notification) {
        resetBalanceCell(for: .credit)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let didLinkAccount = Notification.Name("didLinkAccount")
    static let didUpdateTransactions = Notification.Name("didUpdateTransactions")
    static let cashIsEmptyChanged = Notification.Name("noCashAccounts")
    static let creditCardsIsEmptyChanged = Notification.Name("noCreditCardAccounts")
}
