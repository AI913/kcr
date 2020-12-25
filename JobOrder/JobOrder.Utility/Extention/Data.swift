//
//  Data.swift
//  JobOrder.Utility
//
//  Created by 藤井一暢 on 2020/12/23.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit

extension Data {

    public var isValidImage: Bool {
        return UIImage(data: self) != nil ? true : false
    }

}
