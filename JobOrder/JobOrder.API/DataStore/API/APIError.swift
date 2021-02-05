//
//  APIError.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/12/28.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case invalidStatus(code: Int?, reason: RCSError?)
    case missingContentType
    case unacceptableContentType(String)
    case unsupportedMediaFormat
}
