//
//  Balance.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-22.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Balance: Codable {
    let current: Double
    let available, limit: Double?
}

extension Balance {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Balance.self, from: data)
    }
}
