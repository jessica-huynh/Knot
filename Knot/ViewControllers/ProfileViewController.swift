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
    var spinnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNoValidAccountsAdded(_:)), name: .noValidAccountsAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedAccounts(_:)), name: .updatedAccounts, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessfulLinking(_:)), name: .successfulLinking, object: nil)
        
        spinnerView = createSpinnerView()
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AccountCardViewController, let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            let section = viewModel.sections[indexPath.section] as! ProfileViewModel.AccountsSection
            controller.account = section.accounts[indexPath.row]
        }
    }
    
    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkAccount(_ sender: Any) {
        presentPlaidLink()
    }
    
    @IBAction func eraseAllData(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete All Accounts",
                                      message: "Are you sure you want to proceed? This will remove all linked accounts.",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            [weak self] _ in
            guard let self = self else { return }
            StorageManager.instance.deleteAllAccounts()
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Notification Selectors
    @objc func onSuccessfulLinking(_ notification:Notification) {
        showSpinner(spinnerView: spinnerView, belowNavBar: true)
    }
    
    @objc func onNoValidAccountsAdded(_ notification:Notification) {
        removeSpinner(spinnerView: spinnerView)
    }
    
    @objc func onUpdatedAccounts(_ notification:Notification) {
        viewModel = ProfileViewModel()
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.reloadData()
        removeSpinner(spinnerView: spinnerView)
    }
}
