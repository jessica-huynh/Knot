//
//  StorageManager+Fetching.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-05-08.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit
import BackgroundTasks

extension StorageManager {
    // MARK: Periodic Fetch
    /// Initiates updating of accounts (i.e. calling `fetchAccountUpdates`) if it has been over 24 hours since the last update.
    func fetchAccountUpdatesIfNeeded() {
        let lastFetchUpdate = UserDefaults.standard.object(forKey: "lastFetchUpdate") as! Date
        let timeDifference = Calendar.current.dateComponents([.hour], from: lastFetchUpdate, to: Date()).hour!

        if timeDifference > 24 && !accounts.isEmpty {
            fetchAccountUpdates()
        }
    }
    
    /// Fetches account updates including the current account balance from Plaid
    func fetchAccountUpdates() {
        if isFetchingUpdates { return }
        isFetchingUpdates = true
        NotificationCenter.default.post(name: .beganFetchUpdates, object: nil)
        
        var updatedCashAccounts: [Account] = []
        var updatedCreditAccounts: [Account] = []
        let dispatch = DispatchGroup()
        
        for (accessToken, accountIDs) in accessTokens {
            dispatch.enter()
            PlaidManager.instance.request(for: .getAccounts(accessToken: accessToken, accountIDs: accountIDs)) {
                [weak self] response in
                guard let self = self else { return }
                
                let accounts = try GetAccountsResponse(data: response.data).accounts
                for account in accounts {
                    let oldAccount = self.account(for: account.id)!
                    let updatedAccount = oldAccount.updateBalance(balance: account.balance)
                    
                    if account.type == .depository {
                        updatedCashAccounts.append(updatedAccount)
                    } else {
                        updatedCreditAccounts.append(updatedAccount)
                    }
                }
                dispatch.leave()
            }
        }
        
        dispatch.notify(queue: .main) {
            [weak self] in
            guard let self = self else { return }
            
            self.cashAccounts = updatedCashAccounts
            self.creditAccounts = updatedCreditAccounts
            UserDefaults.standard.set(Date(), forKey: "lastFetchUpdate")
            self.isFetchingUpdates = false
            NotificationCenter.default.post(name: .updatedAccounts, object: self)
        }
    }
    
    // MARK: - Background App Refresh
    func startAppRefresh(_ task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation{ self.fetchAccountUpdates() }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }

        scheduleAppRefresh()
    }

    func scheduleAppRefresh() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "startAppRefresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error)
        }
    }
}

extension Notification.Name {
    static let beganFetchUpdates = Notification.Name("beganFetchUpdates")
}
