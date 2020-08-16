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
        PlaidManager.instance.request(for: .createLinkToken) {
            [weak self] response in
            guard let self = self else { return }
            
            do {
                let createLinkTokenResponse = try CreateLinkTokenResponse(data: response.data)
                
                let linkToken = createLinkTokenResponse.linkToken
                let configuration = PLKConfiguration(linkToken: linkToken)
                let linkViewDelegate = self
                
                let linkViewController = PLKPlaidLinkViewController(
                    linkToken: linkToken,
                    configuration: configuration,
                    delegate: linkViewDelegate)
                
                linkViewController.modalPresentationStyle = presentationStyle
                
                print("Plaid Link setup was successful")
                self.present(linkViewController, animated: true)
            } catch {
                print("Unable to setup Plaid Link")
                self.handleError(error)
            }
        }
    }
    
    func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Woops something went wrong!",
                                      message: "Please try again later.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print(error)
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
