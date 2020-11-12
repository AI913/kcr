//
//  AILibraryAPIRepository.swift
//  JobOrder.API
//
//  Created by Kento Tatsumi on 2020/03/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine

/// AILibrary情報を操作するAPI
/// @mockable
public protocol AILibraryAPIRepository {
    /// AILibrary情報を取得する
    /// - Parameter token: トークン情報
    func fetch(_ token: String) -> AnyPublisher<APIResult<[AILibraryAPIEntity.Data]>, Error>
}
