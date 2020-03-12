//
//  OverviewViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-09.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionCollectionView.register(UINib(nibName: "TransactionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "TransactionCollectionCell")
        transactionCollectionView.dataSource = self
        transactionCollectionView.delegate = self
        transactionCollectionView.showsHorizontalScrollIndicator = false
        
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

