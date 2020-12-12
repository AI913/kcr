//
//  CommandModel.swift
//  JobOrder.Domain
//
//  Created by 藤井一暢 on 2020/12/02.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public struct CommandModel {

    public struct Status {

        public enum Value: String {
            case Open, Close

            public var queryString: String {
                self.rawValue.lowercased()
            }
        }

        /// 実行中のコマンド
        public static var inProgress: [Value] {
            [.Open]
        }

        /// 実行済みのコマンド
        public static var done: [Value] {
            [.Close]
        }
    }

}
