//
//  UIViewController+PlaidDelegate.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-27.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit
import LinkKit

extension UIViewController: PLKPlaidLinkViewDelegate {
    func presentPlaidLink(with presentationStyle: UIModalPresentationStyle = .fullScreen) {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: PlaidManager.instance.linkKitConfiguration, delegate: linkViewDelegate)
        linkViewController.modalPresentationStyle = presentationStyle
        
        self.present(linkViewController, animated: true)
    }
    
    func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Woops something went wrong!",
                                      message: "Please try again later.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Plaid Link View Delegate
    public func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            PlaidManager.instance.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    public func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                print("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error)
            }
        }
    }
}
