//
//  PublicAPIRepository.swift
//  JobOrder.API
//
//  Created by Yu Suzuki on 2021/01/26.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// サインイン不要なAPI
/// @mockable
public protocol PublicAPIRepository {
    /// サーバーの Configuration を取得する
    /// - Parameter name: テナント名
    /// - Returns: Configuratoin データ
    func getServerConfiguration(name: String) -> AnyPublisher<Data, Error>
}
