// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum ActionEntry: String, SegueType {
    case toWorkBenchEntry
    case toWorkObjectEntry
    case toWorkObjectLibrarySelection
    case toWorkObjectLibraryTest
    case toWorkObjectSelection
    case toWorkbenchLibrarySelection
    case unwindToWorkObjectLibrarySelection
    case unwindToWorkObjectSelection
    case unwindToWorkbenchEntry
  }
  internal enum JobEntry: String, SegueType {
    case showConfirm
  }
  internal enum Main: String, SegueType {
    case containerPage
    case showAboutApp
    case showJobDetail
    case showRobotDetail
    case showRobotVideo
    case showSettings
  }
  internal enum OrderEntry: String, SegueType {
    case showComplete
    case showConfigurationForm
    case showConfirm
    case showRobotSelection
  }
  internal enum PasswordAuthentication: String, SegueType {
    case showConnectionSettings
    case showMailVerificationComplete
    case showMailVerificationConfirm
    case showMailVerificationEntry
    case showNewPasswordRequired
  }
  internal enum TaskDetail: String, SegueType {
    case robotSelectionCellToTaskInfo
    case taskDetailRunHistoryCellToRobotSelection
    case taskDetailRunHistoryCellToTaskInformation
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}
