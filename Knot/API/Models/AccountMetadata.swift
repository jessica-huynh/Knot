//
//  AccountMetadata.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

/// Corresponds to Plaid's exchange token response
struct AccountMetadata: Codable {
    let accessToken, itemID: String
    var dateAdded: Date { return Date() }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case itemID = "item_id"
    }
}

extension AccountMetadata {
    init(data: Data) throws {
        self = try JSONDecoder().decode(AccountMetadata.self, from: data)
    }
}
