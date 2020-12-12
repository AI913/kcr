//
//  APIPaging.swift
//  JobOrder.API
//
//  Created by 藤井一暢 on 2020/11/30.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct APIPaging {

    public struct Input: Equatable {
        /// 検索対象のページ位置
        public var page: Int
        /// 取得する件数
        public var size: Int

        public init(page: Int, size: Int) {
            self.page = page
            self.size = size
        }

        public static func == (lhs: Input, rhs: Input) -> Bool {
            return lhs.page == rhs.page &&
                lhs.size == rhs.size
        }
    }

    public struct Output: Codable, Equatable {
        /// 現在のページ/リクエストされたページ
        public var page: Int
        /// 1ページあたりの件数
        public var size: Int
        /// 総ページ数
        public var totalPages: Int
        /// 総件数
        public var totalCount: Int

        public static func == (lhs: Output, rhs: Output) -> Bool {
            return lhs.page == rhs.page &&
                lhs.size == rhs.size &&
                lhs.totalPages == rhs.totalPages &&
                lhs.totalCount == rhs.totalCount
        }
    }

}
