//
//  AppDelegate.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/03/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: DBのプロパティを変更した場合はバージョンをインクリメントする
    private let realmSchemaVersion: UInt64 = 3

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        realmMigration()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

// MARK: - Private Function
extension AppDelegate {

    private func realmMigration() {
        let config = Realm.Configuration(
            schemaVersion: realmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {}
            })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
    }
}
