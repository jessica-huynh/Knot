//
//  AccountCardViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCardViewController: UIViewController {
    let storageManager = StorageManager.instance
    var account: Account!
    
    // MARK: - Outlets
    @IBOutlet weak var accountCard: AccountCard!
    @IBOutlet weak var dateAddedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MMM dd, YYYY"
        let dateAdded = dateFormatter.string(from: account.dateAdded!)
        dateAddedLabel.text = "Added on \(dateAdded)"
        
        accountCard.updateCard(using: account)
    }
    
    // MARK: - Actions
    @IBAction func deleteAccount(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to delete your account?",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            self.storageManager.deleteAccount(account: self.account)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
