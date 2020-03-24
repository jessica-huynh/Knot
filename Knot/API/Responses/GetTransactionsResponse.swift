//
//  GetTransactionsResponse.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-23.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct GetTransactionsResponse: Codable {
    let transactions: [Transaction]
}

extension GetTransactionsResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(GetTransactionsResponse.self, from: data)
    }
}
