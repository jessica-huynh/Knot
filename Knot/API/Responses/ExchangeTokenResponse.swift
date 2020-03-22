//
//  ExchangeTokenResponse.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct ExchangeTokenResponse: Codable {
    let accessToken, itemID: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case itemID = "item_id"
    }
}

extension ExchangeTokenResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(ExchangeTokenResponse.self, from: data)
    }
}
