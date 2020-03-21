//
//  OverviewViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-09.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import Charts
import LinkKit
import Moya

class OverviewViewController: UITableViewController {
    let plaidManager = PlaidManager.instance
    let provider = MoyaProvider<PlaidAPI>()
    
    var transactions: [Transaction]!
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
        
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
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
        presentPlaidLink()
    }
    
    // MARK: - Helper Functions
    
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
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        provider.request(.exchangeTokens(publicToken: publicToken)) {
            result in
            switch result {
            case .success(let response):
                print(try! response.mapJSON())
            case .failure(let error):
                print("Network request failed: \(error)")
                print(try! error.response!.mapJSON())
            }
        }
    }
    
    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }
    
    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Plaid Link setup
    func presentPlaidLink() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: plaidManager.linkKitConfiguration, delegate: linkViewDelegate)

        present(linkViewController, animated: true)
    }
    
    func presentPlaidLinkInUpdateMode() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(publicToken: "<#GENERATED_PUBLIC_TOKEN#>", delegate: linkViewDelegate)
        
        present(linkViewController, animated: true)
    }
}

// MARK: - PLKPlaidLinkViewDelegate Protocol
extension OverviewViewController : PLKPlaidLinkViewDelegate{
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            print("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }

    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                print("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error, metadata: metadata)
            }
            else {
                print("Plaid link exited with metadata: \(metadata ?? [:])")
                self.handleExitWithMetadata(metadata)
            }
        }
    }
}
