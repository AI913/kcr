// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum ActionEntry: StoryboardType {
    internal static let storyboardName = "ActionEntry"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: ActionEntry.self)
  }
  internal enum JobEntry: StoryboardType {
    internal static let storyboardName = "JobEntry"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: JobEntry.self)

    internal static let confirm = SceneType<JobOrder_Presentation.JobEntryConfirmViewController>(storyboard: JobEntry.self, identifier: "Confirm")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let aboutApp = SceneType<JobOrder_Presentation.AboutAppViewController>(storyboard: Main.self, identifier: "AboutApp")

    internal static let dashboard = SceneType<JobOrder_Presentation.DashboardViewController>(storyboard: Main.self, identifier: "Dashboard")

    internal static let jobDetail = SceneType<JobOrder_Presentation.JobDetailViewController>(storyboard: Main.self, identifier: "JobDetail")

    internal static let jobDetailFlow = SceneType<JobOrder_Presentation.JobDetailFlowViewController>(storyboard: Main.self, identifier: "JobDetailFlow")

    internal static let jobDetailRemarks = SceneType<JobOrder_Presentation.JobDetailRemarksViewController>(storyboard: Main.self, identifier: "JobDetailRemarks")

    internal static let jobDetailWork = SceneType<JobOrder_Presentation.JobDetailWorkViewController>(storyboard: Main.self, identifier: "JobDetailWork")

    internal static let jobList = SceneType<JobOrder_Presentation.JobListViewController>(storyboard: Main.self, identifier: "JobList")

    internal static let mainTabBar = SceneType<JobOrder_Presentation.MainTabBarController>(storyboard: Main.self, identifier: "MainTabBar")

    internal static let robotDetail = SceneType<JobOrder_Presentation.RobotDetailViewController>(storyboard: Main.self, identifier: "RobotDetail")

    internal static let robotDetailRemarks = SceneType<JobOrder_Presentation.RobotDetailRemarksViewController>(storyboard: Main.self, identifier: "RobotDetailRemarks")

    internal static let robotDetailSystem = SceneType<JobOrder_Presentation.RobotDetailSystemViewController>(storyboard: Main.self, identifier: "RobotDetailSystem")

    internal static let robotDetailWork = SceneType<JobOrder_Presentation.RobotDetailWorkViewController>(storyboard: Main.self, identifier: "RobotDetailWork")

    internal static let robotList = SceneType<JobOrder_Presentation.RobotListViewController>(storyboard: Main.self, identifier: "RobotList")

    internal static let robotVideo = SceneType<JobOrder_Presentation.RobotVideoViewController>(storyboard: Main.self, identifier: "RobotVideo")

    internal static let settings = SceneType<JobOrder_Presentation.SettingsViewController>(storyboard: Main.self, identifier: "Settings")
  }
  internal enum OrderEntry: StoryboardType {
    internal static let storyboardName = "OrderEntry"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: OrderEntry.self)

    internal static let complete = SceneType<JobOrder_Presentation.OrderEntryCompleteViewController>(storyboard: OrderEntry.self, identifier: "Complete")

    internal static let configurationForm = SceneType<JobOrder_Presentation.OrderEntryConfigurationFormViewController>(storyboard: OrderEntry.self, identifier: "ConfigurationForm")

    internal static let confirm = SceneType<JobOrder_Presentation.OrderEntryConfirmViewController>(storyboard: OrderEntry.self, identifier: "Confirm")

    internal static let jobSelection = SceneType<JobOrder_Presentation.OrderEntryJobSelectionViewController>(storyboard: OrderEntry.self, identifier: "JobSelection")

    internal static let robotSelection = SceneType<JobOrder_Presentation.OrderEntryRobotSelectionViewController>(storyboard: OrderEntry.self, identifier: "RobotSelection")
  }
  internal enum PasswordAuthentication: StoryboardType {
    internal static let storyboardName = "PasswordAuthentication"

    internal static let initialScene = InitialSceneType<JobOrder_Presentation.PasswordAuthenticationNavigationController>(storyboard: PasswordAuthentication.self)

    internal static let connectionSettings = SceneType<JobOrder_Presentation.ConnectionSettingsViewController>(storyboard: PasswordAuthentication.self, identifier: "ConnectionSettings")

    internal static let mailVerificationComplete = SceneType<JobOrder_Presentation.MailVerificationCompleteViewController>(storyboard: PasswordAuthentication.self, identifier: "MailVerificationComplete")

    internal static let mailVerificationConfirm = SceneType<JobOrder_Presentation.MailVerificationConfirmViewController>(storyboard: PasswordAuthentication.self, identifier: "MailVerificationConfirm")

    internal static let mailVerificationEntry = SceneType<JobOrder_Presentation.MailVerificationEntryViewController>(storyboard: PasswordAuthentication.self, identifier: "MailVerificationEntry")

    internal static let newPasswordRequired = SceneType<JobOrder_Presentation.NewPasswordRequiredViewController>(storyboard: PasswordAuthentication.self, identifier: "NewPasswordRequired")

    internal static let passwordAuthentication = SceneType<JobOrder_Presentation.PasswordAuthenticationViewController>(storyboard: PasswordAuthentication.self, identifier: "PasswordAuthentication")

    internal static let passwordAuthenticationNavigation = SceneType<JobOrder_Presentation.PasswordAuthenticationNavigationController>(storyboard: PasswordAuthentication.self, identifier: "PasswordAuthenticationNavigation")
  }
  internal enum TaskDetail: StoryboardType {
    internal static let storyboardName = "TaskDetail"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: TaskDetail.self)

    internal static let robotSelect = SceneType<JobOrder_Presentation.TaskDetailRobotSelectionViewController>(storyboard: TaskDetail.self, identifier: "RobotSelect")

    internal static let robotSelectionNavi = SceneType<UIKit.UINavigationController>(storyboard: TaskDetail.self, identifier: "RobotSelectionNavi")

    internal static let taskDetail = SceneType<JobOrder_Presentation.TaskDetailViewController>(storyboard: TaskDetail.self, identifier: "TaskDetail")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
