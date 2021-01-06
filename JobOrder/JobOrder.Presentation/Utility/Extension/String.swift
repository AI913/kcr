//
//  String.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2020/12/23.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

extension String {
    private func isInclude(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.utf8.count))
        return !matches.isEmpty
    }

    func checkPolicy() -> Bool {
        if self.utf8.count >= 8 {
            if self.isInclude(pattern: "[A-Z]") {
                if self.isInclude(pattern: "[a-z]") {
                    if self.isInclude(pattern: "[0-9]") {
                        if self.isInclude(pattern: "[^A-Za-z0-9]") { // or "[&%$#@]"
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}
