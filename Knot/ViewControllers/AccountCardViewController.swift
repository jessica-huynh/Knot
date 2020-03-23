//
//  AccountCardViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-11.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class AccountCardViewController: UIViewController {

    var account: Account!
    
    // MARK: - Outlets
    @IBOutlet weak var accountCard: AccountCard!
    @IBOutlet weak var dateAddedLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateAddedLabel.text = "Added on Jan 11, 2020"
        updateCard()
    }
    
    // MARK: - Actions
    @IBAction func deleteAccount(_ sender: UIButton) {
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateCard() {
        accountCard.institutionLabel.text = StorageManager.instance.institutions[account.id]!.name
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
