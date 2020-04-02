//
//  Balance.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Balance: Codable {
    let current: Double
    let available, limit: Double?
    
    init(current: Double, available: Double?, limit: Double?) {
        self.current = current
        self.available = available
        self.limit = limit
    }
}

extension Balance {
    convenience init(data: Data) throws {
        let balance = try JSONDecoder().decode(Balance.self, from: data)
        self.init(current: balance.current, available: balance.available,
                  limit: balance.limit)
    }
}
