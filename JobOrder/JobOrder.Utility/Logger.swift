//
//  Logger.swift
//  JobOrder.Utility
//
//  Created by Yuu Suzuki on 2020/03/11.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

// https://qiita.com/shtnkgm/items/cf68a736f81b958c71f9
public struct Logger {

    public static func trace(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .verbose, target: target, file: file, function: function, line: line, message: message)
    }

    public static func verbose(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .verbose, target: target, file: file, function: function, line: line, message: message)
    }

    public static func debug(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .debug, target: target, file: file, function: function, line: line, message: message)
    }

    public static func info(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .info, target: target, file: file, function: function, line: line, message: message)
    }

    public static func warn(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .warn, target: target, file: file, function: function, line: line, message: message)
    }

    public static func error(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .error, target: target, file: file, function: function, line: line, message: message)
    }

    public static func fatal(file: String = #file, function: String = #function, line: Int = #line, target: AnyObject, _ message: String? = nil) {
        printToConsole(logLevel: .error, target: target, file: file, function: function, line: line, message: message)
        assertionFailure(message ?? "")
    }

    private static func printToConsole(logLevel: LogLevel, target: AnyObject, file: String, function: String, line: Int, message: String?) {
        // TODO: ユーザー情報(接続先テナント名: ユーザー名)を追加
        #if DEBUG
        let level = logLevel.rawValue.uppercased().padding(toLength: 7, withPad: " ", startingAt: 0)
        let targetLength = Bundle.targetName(target).length < 16 ? 15 : Bundle.targetName(target).length
        let targetName = Bundle.targetName(target).padding(toLength: targetLength, withPad: " ", startingAt: 0)
        print("\(dateString) \(logLevel.emoji()) \(level) \(targetName) \(className(from: file)).\(function) #\(line) \(message ?? "")")
        #endif
    }

    private enum LogLevel: String {
        case trace, verbose, debug, info, warn, error, fatal

        func emoji() -> String {
            switch self {
            case .trace:    return "🤍"
            case .verbose:  return "💜"
            case .debug:    return "💚"
            case .info:     return "💙"
            case .warn:     return "💛"
            case .error:    return "❤️"
            case .fatal:    return "🖤"
            }
        }
    }

    private static var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    private static func className(from filePath: String) -> String {
        let fileName = filePath.components(separatedBy: "/").last
        return fileName?.components(separatedBy: ".").first ?? ""
    }
}
