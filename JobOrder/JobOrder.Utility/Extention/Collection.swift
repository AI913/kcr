//
//  Collection.swift
//  JobOrder.Utility
//
//  Created by 藤井一暢 on 2020/11/26.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

extension Collection where Element: Publisher {
    public func serialize() -> AnyPublisher<Element.Output, Element.Failure>? {
        guard let start = self.first else { return nil }
        return self.dropFirst().reduce(start.eraseToAnyPublisher()) {
            return $0.append($1).eraseToAnyPublisher()
        }
    }
}
