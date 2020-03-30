//
//  FilterTransactionsViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-30.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class FilterTransactionsViewController: UITableViewController {
    var accounts: [Account]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountFilterCell", for: indexPath)
        let account = accounts[indexPath.row]
        
        cell.textLabel?.text = account.name
        
        if let mask = account.mask {
            cell.textLabel?.text! += " (\(mask))"
        }
        
        cell.detailTextLabel?.text = account.institution.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Accounts"
    }
}
