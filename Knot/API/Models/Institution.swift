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
    let primaryColour, logo: String?
    var colour: String {
        return (primaryColour == nil || primaryColour! == "#ffffff") ? "#dddddd" : primaryColour!
    }

    enum CodingKeys: String, CodingKey {
        case name, logo
        case id = "institution_id"
        case primaryColour = "primary_color"
    }
}

extension Institution {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Institution.self, from: data)
    }
}
