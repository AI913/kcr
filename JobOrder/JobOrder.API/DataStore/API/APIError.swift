//
//  APIError.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

enum APIError: Error {
    case networkError(String?)
    case invalidStatus(Int, String?)
    case noDataInResponse
    case parseError(Error)
    case missingContentType
    case unacceptableContentType(String)
    case unsupportedMediaFormat
}
