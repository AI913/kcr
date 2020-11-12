//
//  SettingsViewData.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import UIKit

/// SettingsViewData
struct SettingsViewData {

    /// Settingsリストメニュー
    enum SettingsMenu: CaseIterable {

        case restoreIdentifier
        case biometricsAuthentication
        case signOut
        case syncData
        case robotVideo
        case aboutApp

        var displayName: String {
            switch self {
            case .restoreIdentifier: return L10n.restoreIdentifier
            case .biometricsAuthentication: return L10n.biometricsAuthentication
            case .signOut: return L10n.signOut
            case .syncData: return L10n.syncCloud
            case .robotVideo: return L10n.robotVideo
            case .aboutApp: return L10n.aboutThisApp
            }
        }

        var remarks: String? {
            switch self {
            case .restoreIdentifier: return nil
            case .biometricsAuthentication: return nil
            case .signOut: return nil
            case .syncData: return nil
            case .robotVideo: return nil
            case .aboutApp: return nil
            }
        }

        var icon: UIImage {
            switch self {
            case .restoreIdentifier: return UIImage(systemName: "lock")!
            case .biometricsAuthentication: return UIImage(systemName: "faceid")!
            case .signOut: return UIImage(systemName: "escape")!
            case .syncData: return UIImage(systemName: "arrow.2.circlepath")!
            case .robotVideo: return UIImage(systemName: "video")!
            case .aboutApp: return UIImage(systemName: "info.circle")!
            }
        }

        var section: SettingsMenuSection {
            switch self {
            case .restoreIdentifier: return .account
            case .biometricsAuthentication: return .account
            case .signOut: return .account
            case .syncData: return .cloud
            case .robotVideo: return .cloud
            case .aboutApp: return .information
            }
        }

        var accessory: UITableViewCell.AccessoryType {
            switch self {
            case .restoreIdentifier: return .none
            case .biometricsAuthentication: return .none
            case .signOut: return .none
            case .syncData: return .none
            case .robotVideo: return .disclosureIndicator
            case .aboutApp: return .disclosureIndicator
            }
        }
    }

    enum SettingsMenuSection: CaseIterable {

        case account
        case cloud
        case information

        var titleForHeader: String {
            switch self {
            case .account: return L10n.account
            case .cloud: return L10n.cloud
            case .information: return L10n.information
            }
        }

        var titleForFooter: String {
            switch self {
            case .account: return ""
            case .cloud: return ""
            case .information: return ""
            }
        }
    }
}
