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
    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var creditCardsBalanceLabel: UILabel!
    @IBOutlet weak var investmentsBalanceLabel: UILabel!
    @IBOutlet weak var transactionCollectionView: UICollectionView!
    @IBOutlet weak var balanceChartView: LineChartView!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidLinkAccount(_:)), name: .didLinkAccount, object: nil)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        setupTransactionCollectionVew()
        setupBalanceChart()
        updateLabels()
    }
    
    // MARK: - Actions
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentPlaidLink()
    }
    
    // MARK: - Helper Functions
    @objc func onDidLinkAccount(_ notification:Notification) {
        updateLabels()
    }
    
    func updateLabels() {
        let cashBalance = calculateBalance(for: storageManager.cashAccounts)
        let creditBalance = calculateBalance(for: storageManager.creditAccounts)
        let investmentBalance = calculateBalance(for: storageManager.investmentAccounts)
        let netBalance = cashBalance - creditBalance + investmentBalance
        
        netBalanceLabel.text = netBalance.toCurrency()!
        cashBalanceLabel.text = cashBalance.toCurrency()!
        creditCardsBalanceLabel.text = creditBalance.toCurrency()!
        investmentsBalanceLabel.text = investmentBalance.toCurrency()!
    }
    
    func calculateBalance(for accounts: [Account]) -> Double {
        var balance = 0.0
        for account in accounts {
            balance += account.balance.current
        }
        
        return balance
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
            
            if segue.identifier == "Cash" {
                controller.viewModel = AccountDetailsViewModel(for: .depository)
            } else if segue.identifier == "Credit Cards" {
                controller.viewModel = AccountDetailsViewModel(for: .credit)
            } else if segue.identifier == "Investments" {
                controller.viewModel = AccountDetailsViewModel(for: .investment)
            } else if segue.identifier == "All Transactions" {
                // Not going to show any accounts, so account type is `nil`:
                controller.viewModel = AccountDetailsViewModel(for: nil)
                // Do not give option to add account from All Transactions scene:
                controller.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
}

// MARK: - Notification Names
extension Notification.Name {
    static let didLinkAccount = Notification.Name("didLinkAccount")
}
