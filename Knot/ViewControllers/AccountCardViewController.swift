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
        let dateAdded = dateFormatter.string(from: account.dateAdded)
        dateAddedLabel.text = "Added on \(dateAdded)"
        
        updateCard()
    }
    
    // MARK: - Actions
    @IBAction func deleteAccount(_ sender: UIButton) {
        storageManager.deleteAccount(account: account)
        NotificationCenter.default.post(name: .updatedAccounts, object: self)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateCard() {
        accountCard.institutionLabel.text = StorageManager.instance.institutionsByID[account.id]!.name
        accountCard.accountTypeLabel.text = account.officialName ?? account.name
        
        if let mask = account.mask {
            accountCard.accountNumberLabel.text = "**** **** **** \(mask)"
        } else {
            accountCard.accountNumberLabel.text = ""
        }
        
        // TODO
        accountCard.nameLabel.text = "Jane Doe"
        accountCard.logoImage.image = UIImage(named: "Logo")
    }

}
