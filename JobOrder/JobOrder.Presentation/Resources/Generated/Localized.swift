// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// About this app
  internal static let aboutThisApp = L10n.tr("Localizable", "about_this_app")
  /// Account
  internal static let account = L10n.tr("Localizable", "account")
  /// Acknowledgment
  internal static let acknowledgment = L10n.tr("Localizable", "acknowledgment")
  /// Biometrics authentication
  internal static let biometricsAuthentication = L10n.tr("Localizable", "biometrics_authentication")
  /// Calibrate to robot
  internal static let calibrateToRobot = L10n.tr("Localizable", "calibrate_to_robot")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// Cloud
  internal static let cloud = L10n.tr("Localizable", "cloud")
  /// Connection status
  internal static let connectionStatus = L10n.tr("Localizable", "connection_status")
  /// Error Count
  internal static let errorCount = L10n.tr("Localizable", "Error Count")
  /// Error Rate
  internal static let errorRate = L10n.tr("Localizable", "Error Rate")
  /// Information
  internal static let information = L10n.tr("Localizable", "information")
  /// Keyword
  internal static let keyword = L10n.tr("Localizable", "keyword")
  /// Open Source
  internal static let openSource = L10n.tr("Localizable", "open_source")
  /// Restore identifier
  internal static let restoreIdentifier = L10n.tr("Localizable", "restore_identifier")
  /// WebRTC Test
  internal static let robotVideo = L10n.tr("Localizable", "robot_video")
  /// Select a job from the list.
  internal static let selectAJobFromTheList = L10n.tr("Localizable", "select_a_job_from_the_list")
  /// Select a robot from the list.
  internal static let selectARobotFromTheList = L10n.tr("Localizable", "select_a_robot_from_the_list")
  /// Sign out
  internal static let signOut = L10n.tr("Localizable", "sign_out")
  /// Sync cloud / edge data
  internal static let syncCloud = L10n.tr("Localizable", "sync_cloud")

  internal enum ActionEntryActionLibrarySelection {
    /// Next
    internal static let bottomButton = L10n.tr("Localizable", "action_entry_action_library_selection.bottom_button")
    /// Please select the action library to use
    internal static let subtitle = L10n.tr("Localizable", "action_entry_action_library_selection.subtitle")
    /// Action Selection
    internal static let title = L10n.tr("Localizable", "action_entry_action_library_selection.title")
  }

  internal enum ActionEntryViewData {
    internal enum WorkLibrary {
      internal enum Name {
        /// Industrial component
        internal static let industrialParts = L10n.tr("Localizable", "action_entry_view_data.work_library.name.industrial_parts")
        /// Spring
        internal static let spring = L10n.tr("Localizable", "action_entry_view_data.work_library.name.spring")
        /// Stationery
        internal static let stationery = L10n.tr("Localizable", "action_entry_view_data.work_library.name.stationery")
      }
    }
  }

  internal enum JobEntryComfirm {
    /// Action Library
    internal static let actionLibrary = L10n.tr("Localizable", "job_entry_comfirm.action_library")
    /// Create
    internal static let bottomButton = L10n.tr("Localizable", "job_entry_comfirm.bottom_button")
    /// Job Name
    internal static let jobName = L10n.tr("Localizable", "job_entry_comfirm.job_name")
    /// Confirm
    internal static let title = L10n.tr("Localizable", "job_entry_comfirm.title")
    /// Work Library
    internal static let workLibrary = L10n.tr("Localizable", "job_entry_comfirm.work_library")
    /// Workbench Library
    internal static let workbenchLibrary = L10n.tr("Localizable", "job_entry_comfirm.workbench_library")
  }

  internal enum JobEntryGeneralInformationForm {
    /// Next
    internal static let bottomButton = L10n.tr("Localizable", "job_entry_general_information_form.bottom_button")
    /// Job name *
    internal static let jobName = L10n.tr("Localizable", "job_entry_general_information_form.job_name")
    /// Remarks
    internal static let remarks = L10n.tr("Localizable", "job_entry_general_information_form.remarks")
    /// Enter basic information
    internal static let subtitle = L10n.tr("Localizable", "job_entry_general_information_form.subtitle")
    /// Basic Info
    internal static let title = L10n.tr("Localizable", "job_entry_general_information_form.title")
  }

  internal enum WorkBenchEntry {
    /// Next
    internal static let bottomButton = L10n.tr("Localizable", "work_bench_entry.bottom_button")
    /// Library
    internal static let library = L10n.tr("Localizable", "work_bench_entry.library")
    /// Unselected
    internal static let notSelected = L10n.tr("Localizable", "work_bench_entry.not_selected")
    /// Select a workbench library
    internal static let subtitle1 = L10n.tr("Localizable", "work_bench_entry.subtitle1")
    /// Select the source workbench
    internal static let subtitle2 = L10n.tr("Localizable", "work_bench_entry.subtitle2")
  }

  internal enum WorkBenchLibrarySelection {
    /// Done
    internal static let bottomButton = L10n.tr("Localizable", "work_bench_library_selection.bottom_button")
    /// Please select the workbench library to use
    internal static let subtitle = L10n.tr("Localizable", "work_bench_library_selection.subtitle")
  }

  internal enum WorkBenchSelection {
    /// Please select the destination workbench
    internal static let subtitle = L10n.tr("Localizable", "work_bench_selection.subtitle")
  }

  internal enum WorkObjectLibrarySelection {
    /// Next
    internal static let bottomButton = L10n.tr("Localizable", "work_object_library_selection.bottom_button")
    /// Please select a library to recognize the workpiece
    internal static let subtitle = L10n.tr("Localizable", "work_object_library_selection.subtitle")
    /// Start test
    internal static let test = L10n.tr("Localizable", "work_object_library_selection.test")
  }

  internal enum WorkObjectLibraryTest {
    /// Recapture
    internal static let bottomButton = L10n.tr("Localizable", "work_object_library_test.bottom_button")
    /// Close
    internal static let leftButton = L10n.tr("Localizable", "work_object_library_test.left_button")
    /// Workpiece recognition test results
    internal static let title = L10n.tr("Localizable", "work_object_library_test.title")
  }

  internal enum WorkObjectSelection {
    /// Done
    internal static let bottomButton = L10n.tr("Localizable", "work_object_selection.bottom_button")
    /// Please select the workpiece to be moved
    internal static let subtitle = L10n.tr("Localizable", "work_object_selection.subtitle")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
