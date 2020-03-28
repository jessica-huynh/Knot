//
//  ProfileViewController.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-09.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    var viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        
        tableView.dataSource = viewModel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkAccount(_ sender: Any) {
        presentPlaidLink()
    }
    
    @IBAction func eraseAllData(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure you want to proceed?",
                                      message: "This will remove all data including any linked account(s).",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AccountCardViewController, let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            let section = viewModel.sections[indexPath.section] as! ProfileViewModelAccounts
            controller.account = section.accounts[indexPath.row]
        }
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        viewModel = ProfileViewModel()
        tableView.dataSource = viewModel
        tableView.reloadData()
    }
}
