//
//  DataManageModel.swift
//  JobOrder.Domain
//
//  Created by Kento Tatsumi on 2020/04/03.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import JobOrder_Data
import JobOrder_API

/// DataManageモデル
public struct DataManageModel {

    /// Presentationへ出力するためのデータ形式
    public struct Output {

        /// API同期データ
        public struct SyncData {
            /// Jobデータ
            public var jobs: [Job]? = []
            /// Robotデータ
            public var robots: [Robot]? = []
            /// ActionLibraryデータ
            public var actionLibraries: [ActionLibrary]? = []
            /// AILibraryデータ
            public var aiLibraries: [AILibrary]? = []
        }

        public struct RemoveData {
            public let result: Bool
        }

        /// Jobデータ
        public struct Job {
            /// ID
            public let id: String
            /// 名前
            public let name: String
            /// アクション
            public var actions: [Action] = []
            /// エントリーポイント
            public let entryPoint: Int
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// 要求事項
            public var requirements: [Requirement] = []
            /// バージョン
            public let version: Int
            /// 作成日時
            public let createTime: Int
            /// 作成者
            public let creator: String
            /// 更新日時
            public let updateTime: Int
            /// 更新者
            public let updator: String

            /// Jobで実行できるActionLibrary情報
            public struct Action {
                /// インデックス
                public let index: Int
                /// ID
                public let id: String
                /// パラメータ
                public let parameter: Parameter?
                /// catch
                public let _catch: String?
                /// then
                public let then: String?

                public struct Parameter {}
            }

            public struct Requirement {}

        }

        /// Robotデータ
        public struct Robot {
            /// ID
            public let id: String
            /// 名前
            public let name: String?
            /// タイプ
            public let type: String
            /// 言語
            public let locale: String
            /// シミュレータかどうか
            public let isSimulator: Bool
            /// メーカー
            public let maker: String?
            /// モデル
            public let model: String?
            /// モデルクラス
            public let modelClass: String?
            /// シリアル番号
            public let serial: String?
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// バージョン
            public let version: Int
            /// 作成日時
            public let createTime: Int
            /// 作成者
            public let creator: String
            /// 更新日時
            public let updateTime: Int
            /// 更新者
            public let updator: String
            /// Thing名
            public let thingName: String?
            /// ARN
            public let thingArn: String?
            /// 稼働状態
            public let state: State?

            /// 稼働状態
            public enum State: CaseIterable {
                /// 不明
                case unknown
                /// 中断中
                case terminated
                /// 停止中
                case stopped
                /// 稼働中
                case starting
                /// 稼働待ち
                case waiting
                /// 処理中
                case processing

                /// 稼働状態のキー
                var key: String {
                    switch self {
                    case .unknown: return "unknown"
                    case .terminated: return "terminated"
                    case .stopped: return "stopped"
                    case .starting: return "starting"
                    case .waiting: return "waiting"
                    case .processing: return "processing"
                    }
                }

                static func toEnum(_ value: String?) -> State? {
                    guard let value = value else { return nil }

                    for state in State.allCases where value == state.key {
                        return state
                    }
                    return .unknown
                }
            }
        }

        public struct Command {
            public let taskId: String
            public let robotId: String
            public let started: Int?
            public let exited: Int?
            public let execDuration: Int?
            public let receivedStartReort: Int?
            public let receivedExitReort: Int?
            public let status: String
            public let resultInfo: String?
            public let success: Int
            public let fail: Int
            public let error: Int
            public let robot: Robot?
            public let dataVersion: Int
            public let createTime: Int
            public let creator: String
            public let updateTime: Int
            public let updator: String
        }

        public struct Task {
            public let id: String
            public let jobId: String
            public let robotIds: [String]
            public let exit: Exit
            public let job: Job
            public let createTime: Int
            public let creator: String
            public let updateTime: Int
            public let updator: String

            public struct Exit {
                public let option: Option

                public struct Option {
                    public let numberOfRuns: Int?
                }
            }
        }

        /// Robot Systemデータ
        public struct System {
            public let softwareConfiguration: SoftwareConfiguration
            public let hardwareConfigurations: [HardwareConfiguration]

            public struct SoftwareConfiguration {
                public let system: String
                public let distribution: String
                public let installs: [Installed]

                public struct Installed {
                    public let name: String
                    public let version: String
                }
            }

            public struct HardwareConfiguration {
                public let type: String
                public let model: String
                public let maker: String
                public let serialNo: String
            }
        }

        /// ActionLibraryデータ
        public struct ActionLibrary {
            /// ID
            public let id: String
            /// 名前
            public let name: String
            /// 要求事項
            public var requirements: [Requirement] = []
            /// 画像パス
            public let imagePath: String?
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// バージョン
            public let version: Int
            /// 作成日時
            public let createTime: Int
            /// 作成者
            public let creator: String
            /// 更新日時
            public let updateTime: Int
            /// 更新者
            public let updator: String

            public struct Requirement {}
        }

        /// AILibraryデータ
        public struct AILibrary {
            /// ID
            public let id: String
            /// 名前
            public let name: String
            /// タイプ
            public let type: String
            /// 要求事項
            public var requirements: [Requirement] = []
            /// 画像パス
            public let imagePath: String?
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// バージョン
            public let version: Int
            /// 作成日時
            public let createTime: Int
            /// 作成者
            public let creator: String
            /// 更新日時
            public let updateTime: Int
            /// 更新者
            public let updator: String

            public struct Requirement {}
        }

        /// Robot画像
        public struct RobotImage {
            /// 画像データ
            public let data: Data?
        }

        /// Executionログ
        public struct ExecutionLog {
            public let id: String
            public let executedAt: Int
            public let result: String
        }
    }

    public struct Input {
        /// PostTask用データ
        public struct Task {
            public let jobId: String
            public let robotIds: [String]
            public let start: Start
            public let exit: Exit

            public struct Start {
                public let condition: String
                // FIXME: option仕様待ち

                enum CodingKeys: String, CodingKey {
                    case condition
                }
            }

            public struct Exit {
                public let condition: String
                public let option: Option

                enum CodingKeys: String, CodingKey {
                    case condition
                    case option
                }

                public struct Option {
                    public let numberOfRuns: Int?

                    enum CodingKeys: String, CodingKey {
                        case numberOfRuns
                    }
                }
            }
        }
        /// PostJob用データ
        public struct Job {
            /// 表示名称
            public let name: String
            /// アクション情報
            public let actions: [Action]
            /// エントリポイント
            public let entryPoint: Int
            /// 概要
            public let overview: String?
            /// 備考
            public let remarks: String?
            /// 実行要件
            public let requirements: [Requirement]?

            /// 該当ジョブのアクション情報
            public struct Action {
                /// インデックス
                public let index: Int
                /// アクションライブラリ識別子(UUID)
                public let actionLibraryId: String
                /// 該当アクションで用いるアクションライブラリの識別子
                public let parameter: Parameter?
                /// 後続処理情報群（失敗）
                public let `catch`: String?
                /// 後続処理情報群（成功）
                public let `then`: String?

                /// アクションで実行時引数となるパラメータオブジェクト情報
                public struct Parameter {
                    /// AIライブラリ識別子(UUID)
                    public let aiLibraryId: String?
                    /// AIライブラリ分類識別子
                    public let aiLibraryObjectId: String?
                }

            }

            /// 実行要件
            public struct Requirement {
                public let type: String
                public let subtype: String
                public let id: String?
                public let versionId: String?
            }
        }
    }
}

// MARK: - Equatable
extension DataManageModel.Output.System: Equatable {
    public static func == (lhs: DataManageModel.Output.System, rhs: DataManageModel.Output.System) -> Bool {
        return lhs.softwareConfiguration == rhs.softwareConfiguration &&
            lhs.hardwareConfigurations.elementsEqual(rhs.hardwareConfigurations, by: { $0 == $1 })
    }
}

extension DataManageModel.Output.System.SoftwareConfiguration: Equatable {
    public static func == (lhs: DataManageModel.Output.System.SoftwareConfiguration, rhs: DataManageModel.Output.System.SoftwareConfiguration) -> Bool {
        return lhs.system == rhs.system &&
            lhs.distribution == rhs.distribution &&
            lhs.installs.elementsEqual(rhs.installs, by: { $0 == $1 })
    }
}

extension DataManageModel.Output.System.SoftwareConfiguration.Installed: Equatable {
    public static func == (lhs: DataManageModel.Output.System.SoftwareConfiguration.Installed, rhs: DataManageModel.Output.System.SoftwareConfiguration.Installed) -> Bool {
        return lhs.name == rhs.name &&
            lhs.version == rhs.version
    }
}

extension DataManageModel.Output.System.HardwareConfiguration: Equatable {
    public static func == (lhs: DataManageModel.Output.System.HardwareConfiguration, rhs: DataManageModel.Output.System.HardwareConfiguration) -> Bool {
        return lhs.type == rhs.type &&
            lhs.model == rhs.model &&
            lhs.maker == rhs.maker &&
            lhs.serialNo == rhs.serialNo
    }
}
