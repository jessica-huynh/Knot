//
//  GetInstitutionResponse.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-31.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation

struct GetInstitutionResponse: Codable {
    let institution: Institution
}

extension GetInstitutionResponse {
    init(data: Data) throws {
        self = try JSONDecoder().decode(GetInstitutionResponse.self, from: data)
    }
}
