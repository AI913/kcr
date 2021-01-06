//
//  AppDelegate.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/03/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import JobOrder_API

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: DBのプロパティを変更した場合はバージョンをインクリメントする
    private let realmSchemaVersion: UInt64 = 3
    private var analytics: JobOrder_API.AnalyticsServiceRepository?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        realmMigration()
        analytics = AWSAnalyticsDataStore(launchOptions)
        registerForPushNotifications()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    // MARK: Remote Notifications Lifecycle
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        analytics?.registerDevice(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                        -> Void) {
        analytics?.passRemoteNotificationEvent(userInfo)
        completionHandler(.newData)
    }
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

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }

                // Only get the notification settings if user has granted permissions
                self?.getNotificationSettings()
            }
    }

    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                // Register with Apple Push Notification service
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
