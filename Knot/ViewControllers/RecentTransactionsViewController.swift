//
//  RecentTransactionsViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class RecentTransactionsViewController: UITableViewController {
    var recentTransactions: [Transaction]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "ReachedEndCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ReachedEndCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentTransactions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTransactionCell", for: indexPath) as! RecentTransactionCell
        cell.configure(using: recentTransactions[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "Transactions of Last 7 Days"
     }
}
