//
//  QueryBuilder.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/12/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

class QueryBuilder {

    private var items: [URLQueryItem]

    init() {
        self.items = [URLQueryItem]()
    }

    func build() -> [URLQueryItem]? {
        guard !self.items.isEmpty else { return nil }
        return self.items
    }

    func add(name: String, value: String?) -> QueryBuilder {
        self.items.append(URLQueryItem(name: name, value: value))
        return self
    }

    func add(status: [String]?) -> QueryBuilder {
        if let status = status {
            status.forEach { _ = self.add(name: "status", value: $0) }
        }
        return self
    }

    func add(paging: APIPaging.Input?) -> QueryBuilder {
        if let paging = paging {
            _ = self.add(name: "page", value: String(paging.page))
            _ = self.add(name: "size", value: String(paging.size))
        }
        return self
    }

}
