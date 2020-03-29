//
//  PlaidAPI.swift
//  Knot
//
//  Created by Jessica Huynh on 2020-03-20.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//
import Foundation
import Moya

enum PlaidAPI {
    static let clientID = PlaidManager.instance.clientID
    static let secret = PlaidManager.instance.secret
    static let environment = PlaidManager.instance.environment
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    case exchangeTokens(publicToken: String)
    case getAccounts(accessToken: String)
    case getTransactions(accessToken: String, startDate: Date, endDate: Date, accountIDs: [String]? = nil)
}

extension PlaidAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://\(PlaidAPI.environment).plaid.com")!
    }

    public var path: String {
        switch self {
        case .exchangeTokens(_):
            return "/item/public_token/exchange"
        case .getAccounts(_):
            return "/accounts/get"
        case .getTransactions:
            return "/transactions/get"
        }
    }

    public var method: Moya.Method {
        return .post
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case .exchangeTokens(let publicToken):
            return .requestParameters(
                parameters: [
                    "client_id": PlaidAPI.clientID,
                    "secret": PlaidAPI.secret,
                    "public_token": publicToken],
                encoding: JSONEncoding.default)
            
        case .getAccounts(let accessToken):
            return .requestParameters(
            parameters: [
                "client_id": PlaidAPI.clientID,
                "secret": PlaidAPI.secret,
                "access_token": accessToken],
            encoding: JSONEncoding.default)
            
        case .getTransactions(let accessToken, let startDate, let endDate, let accountIDs):
            return .requestParameters(
            parameters: [
                "client_id": PlaidAPI.clientID,
                "secret": PlaidAPI.secret,
                "access_token": accessToken,
                "start_date": PlaidAPI.dateFormatter.string(from: startDate),
                "end_date": PlaidAPI.dateFormatter.string(from: endDate),
                "options": [
                    "count": 500,
                    "account_ids": accountIDs as Any]],
            encoding: JSONEncoding.default)
        }
    }

    public var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }

    public var validationType: ValidationType {
      return .successCodes
    }
}
