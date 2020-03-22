//
//  Institution.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct Institution: Codable {
    let name, id: String

    enum CodingKeys: String, CodingKey {
        case name
        case id = "institution_id"
    }
}

extension Institution {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Institution.self, from: data)
    }
}
