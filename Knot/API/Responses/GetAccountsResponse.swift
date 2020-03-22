//
//  GetAccountsResponse.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct GetAccountsResponse: Codable {
    let accounts: [Account]
}

extension GetAccountsResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(GetAccountsResponse.self, from: data)
    }
}
