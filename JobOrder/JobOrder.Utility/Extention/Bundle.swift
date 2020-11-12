//
//  Bundle.swift
//  JobOrder.Utility
//
//  Created by Yu Suzuki on 2020/06/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

extension Bundle {

    public static func targetName(_ anyClass: AnyObject) -> String {
        let bundle = Bundle(for: type(of: anyClass))
        return bundle.object(forInfoDictionaryKey: "Target Name") as? String ?? ""
    }
}
