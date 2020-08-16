//
//  CreateLinkTokenResponse.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-08-16.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct CreateLinkTokenResponse: Codable {
    let linkToken: String
    
    enum CodingKeys: String, CodingKey {
        case linkToken = "link_token"
    }
}

extension CreateLinkTokenResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(CreateLinkTokenResponse.self, from: data)
    }
}
