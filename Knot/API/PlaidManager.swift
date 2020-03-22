//
//  PlaidManager.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-20.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import LinkKit
import Keys

class PlaidManager {
    static let instance = PlaidManager()
    
    let publicKey: String, clientID: String, secret: String, environment: Environment
    
    enum Environment: String {
        case sandbox, development
        
        var linkKitValue: PLKEnvironment {
            switch self {
            case .sandbox: return .sandbox
            case .development: return .development
            }
        }
    }
    
    private init() {
        let keys = KnotKeys()
        publicKey = keys.publicKey
        clientID = keys.clientID
        environment = .sandbox // Change Plaid environment from here
        secret = (environment == .sandbox) ? keys.secret_sandbox : keys.secret_development
    }
    
    func setupPlaid() {
        PLKPlaidLink.setup(with: linkKitConfiguration) { (success, error) in
            if success {
                print("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
            }
            else if let error = error {
                print("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                print("Unable to setup Plaid Link")
            }
        }
    }
    
    var linkKitConfiguration: PLKConfiguration {
        let configuration = PLKConfiguration(key: publicKey, env: environment.linkKitValue, product: .transactions)
        configuration.clientName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
        configuration.countryCodes = ["US", "CA"]
        return configuration
    }
}
