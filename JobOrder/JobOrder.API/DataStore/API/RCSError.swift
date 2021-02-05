//
//  RCSError.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2021/01/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation

public enum RCSError: Error {

    public struct APIGatewayErrorResponse: Codable {
        let type: String
        let resourcePath: String
        let message: String
        let details: String
    }

    public struct LamdbaFunctionErrorResponse: Codable {
        let time: Int
        let errors: [ErrorObject]

        struct ErrorObject: Codable {
            let code: String
            let field: String?
            let value: String?
            let description: String
        }

        public var errorCode: String? {
            guard let error = errors.first else { return nil }
            return error.code
        }

        public var errorDescription: String? {
            guard let error = errors.first else { return nil }
            return error.description
        }
    }

    case apiGatewayError(response: APIGatewayErrorResponse)
    case lambdaFunctionError(response: LamdbaFunctionErrorResponse)
    case unknownError(data: Data?)

    init(from data: Data) {
        let response: RCSError.APIGatewayErrorResponse
        do {
            response = try JSONDecoder().decode(APIGatewayErrorResponse.self, from: data)
        } catch {
            let response: RCSError.LamdbaFunctionErrorResponse
            do {
                response = try JSONDecoder().decode(LamdbaFunctionErrorResponse.self, from: data)
            } catch {
                self = .unknownError(data: data)
                return
            }
            self = .lambdaFunctionError(response: response)
            return
        }
        self = .apiGatewayError(response: response)
    }
}
