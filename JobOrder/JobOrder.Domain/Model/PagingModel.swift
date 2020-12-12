//
//  PagingModel.swift
//  JobOrder.Domain
//
//  Created by 藤井一暢 on 2020/11/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_API

public struct PagingModel {

    public struct PaginatedResult<T: Sequence> {
        /// データ本体
        public let data: T
        /// ページングカーソル
        public let cursor: Cursor?
        /// 全データ数(ページング関係なく)
        public let total: Int?

        init(data: T, cursor: Cursor?, total: Int?) {
            self.data = data
            self.cursor = cursor
            self.total = total
        }

        init(data: T, paging: JobOrder_API.APIPaging.Output?) {
            self.data = data
            self.cursor = Cursor(paging: paging)
            self.total = paging?.totalCount
        }
    }

    public struct Cursor: Equatable {
        /// 先頭からのオフセット
        public var offset: Int
        /// データ数(要求時は常に一定とする)
        public var limit: Int

        public init?(offset: Int, limit: Int) {
            guard offset >= 0 else { return nil }
            guard limit > 0 else { return nil }

            self.offset = offset
            self.limit = limit
        }

        init?(paging: JobOrder_API.APIPaging.Output?) {
            guard let paging = paging, paging.size > 0 else { return nil }

            let offset = paging.size * (paging.page - 1)
            guard offset >= 0 else { return nil }

            self.offset = offset
            self.limit = paging.size
        }

        public func toPaging() -> JobOrder_API.APIPaging.Input {
            let page = self.offset / self.limit + 1
            let size = self.limit
            return JobOrder_API.APIPaging.Input(page: page, size: size)
        }

        public static func == (lhs: Cursor, rhs: Cursor) -> Bool {
            return lhs.offset == rhs.offset &&
                lhs.limit == rhs.limit
        }

    }

}
