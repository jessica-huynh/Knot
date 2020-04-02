//
//  Institution.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-21.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

class Institution: Codable {
    let name, id: String
    let primaryColour, logo: String?

    enum CodingKeys: String, CodingKey {
        case name, logo
        case id = "institution_id"
        case primaryColour = "primary_color"
    }
    
    init(name: String, id: String, primaryColour: String?, logo: String?) {
        self.name = name
        self.id = id
        self.primaryColour = primaryColour
        self.logo = logo
    }
}

extension Institution {
    convenience init(data: Data) throws {
        let institution = try JSONDecoder().decode(Institution.self, from: data)
        self.init(name: institution.name,
                  id: institution.id,
                  primaryColour: institution.primaryColour,
                  logo: institution.logo)
    }
}
