//
//  StorageManager.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class StorageManager {
    static let instance = StorageManager()
    
    var accountMetadata: [String : AccountMetadata] = [:]
    var institutions: [String : Institution] = [:]
    var cashAccounts: [Account] = []
    var creditAccounts: [Account] = []
    var investmentAccounts: [Account] = []
    
    private init() {
        // Load from CoreData here
    }
    
}
