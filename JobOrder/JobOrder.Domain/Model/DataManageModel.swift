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

            /// エンティティ -> モデル変換
            /// - Parameters:
            ///   - jobEntities: Jobエンティティ
            ///   - robotEntities: Robotエンティティ
            ///   - actionLibraryEntities: ActionLibraryエンティティ
            ///   - aiLibraryEntities: AILibraryエンティティ
            init(jobEntities: [JobOrder_Data.JobEntity]?,
                 robotEntities: [JobOrder_Data.RobotEntity]?,
                 actionLibraryEntities: [JobOrder_Data.ActionLibraryEntity]?,
                 aiLibraryEntities: [JobOrder_Data.AILibraryEntity]?) {

                self.jobs = jobEntities?.map { Job($0) }
                self.robots = robotEntities?.map { Robot($0) }
                self.actionLibraries = actionLibraryEntities?.map { ActionLibrary($0) }
                self.aiLibraries = aiLibraryEntities?.map { AILibrary($0) }
            }
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
            public let requirements: String?
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

            /// イニシャライザ
            /// - Parameters:
            /// 更新者
            ///   - id: ID
            ///   - name: 名前
            ///   - actions: アクション
            ///   - entryPoint: エントリーポイント
            ///   - overview: 概要
            ///   - remarks: 備考
            ///   - requirements: 要求事項
            ///   - version: バージョン
            ///   - createTime: 作成日時
            ///   - creator: 作成者
            ///   - updateTime: 更新日時
            ///   - updator: 更新者
            public init(id: String, name: String, actions: [Action], entryPoint: Int, overview: String?, remarks: String?, requirements: String?, version: Int, createTime: Int, creator: String, updateTime: Int, updator: String) {
                self.id = id
                self.name = name
                self.actions.append(contentsOf: Array(actions))
                self.entryPoint = entryPoint
                self.overview = overview
                self.remarks = remarks
                self.requirements = requirements
                self.version = version
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
            }

            /// エンティティ -> モデル変換
            /// - Parameter job: Jobエンティティ
            init(_ job: JobOrder_Data.JobEntity) {
                self.id = job.id
                self.name = job.name
                self.actions.append(contentsOf: Array(actions))
                self.entryPoint = job.entryPoint
                self.overview = job.overview
                self.remarks = job.remarks
                self.requirements = job.requirements
                self.version = job.version
                self.createTime = job.createTime
                self.creator = job.creator
                self.updateTime = job.updateTime
                self.updator = job.updator
            }

            /// エンティティ -> モデル変換
            /// - Parameter job: Jobエンティティ
            init(_ job: JobOrder_API.JobAPIEntity.Data) {
                self.id = job.id
                self.name = job.name
                self.actions.append(contentsOf: Array(actions))
                self.entryPoint = job.entryPoint
                self.overview = job.overview
                self.remarks = job.remarks
                self.requirements = job.requirements
                self.version = job.version
                self.createTime = job.createTime
                self.creator = job.creator
                self.updateTime = job.updateTime
                self.updator = job.updator
            }

            static func == (lhs: Job, rhs: Job) -> Bool {
                return lhs.id == rhs.id &&
                    lhs.name == rhs.name &&
                    lhs.actions == rhs.actions &&
                    lhs.entryPoint == rhs.entryPoint &&
                    lhs.overview == rhs.overview &&
                    lhs.remarks == rhs.remarks &&
                    lhs.requirements == rhs.requirements &&
                    lhs.version == rhs.version &&
                    lhs.createTime == rhs.createTime &&
                    lhs.creator == rhs.creator &&
                    lhs.updateTime == rhs.updateTime &&
                    lhs.updator == rhs.updator
            }

            /// Jobで実行できるActionLibrary情報
            public struct Action: Equatable {
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

                public static func == (lhs: Action, rhs: Action) -> Bool {
                    return lhs.index == rhs.index &&
                        lhs.id == rhs.id &&
                        lhs.parameter == rhs.parameter &&
                        lhs._catch == rhs._catch &&
                        lhs.then == rhs.then
                }

                public struct Parameter: Equatable {

                    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
                        return true
                    }
                }
            }
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

            /// イニシャライザ
            /// - Parameters:
            /// 更新者
            ///   - id: ID
            ///   - name: 名前
            ///   - type: タイプ
            ///   - isSimulator: シミュレータかどうか
            ///   - maker: メーカー
            ///   - model: モデル
            ///   - modelClass: モデルクラス
            ///   - serial: シリアル番号
            ///   - overview: 概要
            ///   - remarks: 備考
            ///   - version: バージョン
            ///   - createTime: 作成日時
            ///   - creator: 作成者
            ///   - updateTime: 更新日時
            ///   - updator: 更新者
            ///   - thingName: Thing名
            ///   - thingArn: ARN
            ///   - state: 稼働状態
            public init(id: String, name: String, type: String, locale: String, isSimulator: Bool, maker: String?, model: String?, modelClass: String?, serial: String?, overview: String?, remarks: String?, version: Int, createTime: Int, creator: String, updateTime: Int, updator: String, thingName: String?, thingArn: String?, state: String) {
                self.id = id
                self.name = name
                self.type = type
                self.locale = locale
                self.isSimulator = isSimulator
                self.maker = maker
                self.model = model
                self.modelClass = modelClass
                self.serial = serial
                self.overview = overview
                self.remarks = remarks
                self.version = version
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
                self.thingName = thingName
                self.thingArn = thingArn
                self.state = State.toEnum(state)
            }

            /// エンティティ -> モデル変換
            /// - Parameter robot: Robotエンティティ
            init(_ robot: JobOrder_Data.RobotEntity) {

                self.id = robot.id
                self.name = robot.name
                self.type = robot.type
                self.locale = robot.locale
                self.isSimulator = robot.isSimulator
                self.maker = robot.maker
                self.model = robot.model
                self.modelClass = robot.modelClass
                self.serial = robot.serial
                self.overview = robot.overview
                self.remarks = robot.remarks
                self.version = robot.version
                self.createTime = robot.createTime
                self.creator = robot.creator
                self.updateTime = robot.updateTime
                self.updator = robot.updator
                self.thingName = robot.thingName
                self.thingArn = robot.thingArn
                self.state = State.toEnum(robot.state)
            }

            init(_ robot: JobOrder_API.RobotAPIEntity.Data) {
                self.id = robot.id
                self.name = robot.name
                self.type = robot.type
                self.locale = robot.locale
                self.isSimulator = robot.isSimulator
                self.maker = robot.maker
                self.model = robot.model
                self.modelClass = robot.modelClass
                self.serial = robot.serial
                self.overview = robot.overview
                self.remarks = robot.remarks
                self.version = robot.version
                self.createTime = robot.createTime
                self.creator = robot.creator
                self.updateTime = robot.updateTime
                self.updator = robot.updator
                self.thingName = robot.awsKey?.thingName
                self.thingArn = robot.awsKey?.thingArn
                //TODO:RobotのAPIから返ってこない値がinitに必要？
                self.state = State.toEnum("")
            }

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

            static func == (lhs: Robot, rhs: Robot) -> Bool {
                return lhs.id == rhs.id &&
                    lhs.name == rhs.name &&
                    lhs.type == rhs.type &&
                    lhs.model == rhs.model &&
                    lhs.modelClass == rhs.modelClass &&
                    lhs.maker == rhs.maker &&
                    lhs.serial == rhs.serial &&
                    lhs.overview == rhs.overview &&
                    lhs.remarks == rhs.remarks &&
                    lhs.thingName == rhs.thingName &&
                    lhs.thingArn == rhs.thingArn &&
                    lhs.state == rhs.state
            }
        }

        public struct Command: Equatable {
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

            /// イニシャライザ
            /// - Parameters:
            /// 更新者
            ///   - id: ID
            ///   - name: 名前
            ///   - requirements: 要求事項
            ///   - imagePath: 画像パス
            ///   - version: バージョン
            ///   - createTime: 作成日時
            ///   - creator: 作成者
            ///   - updateTime: 更新日時
            ///   - updator: 更新者
            public init(taskId: String, robotId: String, started: Int, exited: Int, execDuration: Int, receivedStartReort: Int, receivedExitReort: Int, status: String, resultInfo: String, success: Int, fail: Int, error: Int, robot: Robot?, dataVersion: Int, createTime: Int, creator: String, updateTime: Int, updator: String) {
                self.taskId = taskId
                self.robotId = robotId
                self.started = started
                self.exited = exited
                self.execDuration = execDuration
                self.receivedStartReort = receivedStartReort
                self.receivedExitReort = receivedExitReort
                self.status = status
                self.resultInfo = resultInfo
                self.success = success
                self.fail = fail
                self.error = error
                self.robot = robot
                self.dataVersion = dataVersion
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
            }

            /// エンティティ -> モデル変換
            /// - Parameter RobotCommand: RobotCommandエンティティ
            init(_ robotCommand: JobOrder_API.CommandEntity.Data) {
                self.taskId = robotCommand.taskId
                self.robotId = robotCommand.robotId
                self.started = robotCommand.started
                self.exited = robotCommand.exited
                self.execDuration = robotCommand.execDuration
                self.receivedStartReort = robotCommand.receivedStartReort
                self.receivedExitReort = robotCommand.receivedExitReort
                self.status = robotCommand.status
                self.resultInfo = robotCommand.resultInfo
                self.success = robotCommand.success
                self.fail = robotCommand.fail
                self.error = robotCommand.error
                if let robot = robotCommand.robot {
                    self.robot = Robot(robot.robotInfo)
                } else {
                    self.robot = nil
                }
                self.dataVersion = robotCommand.dataVersion
                self.createTime = robotCommand.createTime
                self.creator = robotCommand.creator
                self.updateTime = robotCommand.updateTime
                self.updator = robotCommand.updator
            }

            public static func == (lhs: Command, rhs: Command) -> Bool {
                return lhs.taskId == rhs.taskId &&
                    lhs.taskId == rhs.taskId &&
                    lhs.robotId == rhs.robotId &&
                    lhs.started == rhs.started &&
                    lhs.exited == rhs.exited &&
                    lhs.execDuration == rhs.execDuration &&
                    lhs.receivedStartReort == rhs.receivedStartReort &&
                    lhs.receivedExitReort == rhs.receivedExitReort &&
                    lhs.status == rhs.status &&
                    lhs.resultInfo == rhs.resultInfo &&
                    lhs.success == rhs.success &&
                    lhs.fail == rhs.fail &&
                    lhs.error == rhs.error &&
                    lhs.dataVersion == rhs.dataVersion &&
                    lhs.createTime == rhs.createTime &&
                    lhs.creator == rhs.creator &&
                    lhs.updateTime == rhs.updateTime &&
                    lhs.updator == rhs.updator
            }
        }

        public struct Task: Equatable {
            public let id: String
            public let jobId: String
            public let robotIds: [String]
            public let exit: Exit
            public let job: Job
            public let createTime: Int
            public let creator: String
            public let updateTime: Int
            public let updator: String

            public static func == (lhs: Task, rhs: Task) -> Bool {
                return lhs.id == rhs.id &&
                    lhs.jobId == rhs.jobId &&
                    lhs.robotIds == rhs.robotIds &&
                    lhs.exit == rhs.exit &&
                    lhs.job == rhs.job &&
                    lhs.createTime == rhs.createTime &&
                    lhs.creator == rhs.creator &&
                    lhs.updateTime == rhs.updateTime &&
                    lhs.updator == rhs.updator
            }

            public struct Exit: Codable {
                public let option: Option

                public static func == (lhs: Exit, rhs: Exit) -> Bool {
                    return lhs.option == rhs.option
                }
                public init(_ option: Option) {
                    self.option = option
                }
                public init(_ exit: TaskAPIEntity.Data.Exit) {
                    self.option = Option(exit.option)
                }

                public struct Option: Codable {
                    public let numberOfRuns: Int?

                    public static func == (lhs: Option, rhs: Option) -> Bool {
                        return lhs.numberOfRuns == rhs.numberOfRuns
                    }

                    public init(_ numberOfRuns: Int) {
                        self.numberOfRuns = numberOfRuns
                    }
                    public init(_ option: TaskAPIEntity.Data.Exit.Option) {
                        self.numberOfRuns = option.numberOfRuns
                    }
                }
            }

            public init(id: String, jobId: String, robotIds: [String], exit: Exit, job: Job, createTime: Int, creator: String, updateTime: Int, updator: String) {
                self.id = id
                self.jobId = jobId
                self.robotIds = robotIds
                self.exit = exit
                self.job = job
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
            }

            public init(_ task: TaskAPIEntity.Data) {
                self.id = task.id
                self.jobId = task.jobId
                self.robotIds = task.robotIds
                self.exit = Exit(task.exit)
                self.job = Job(task.job)
                self.createTime = task.createTime
                self.creator = task.creator
                self.updateTime = task.updateTime
                self.updator = task.updator
            }
        }

        /// Robot Systemデータ
        public struct System {
            public let softwareConfiguration: SoftwareConfiguration
            public let hardwareConfigurations: [HardwareConfiguration]

            public init(softwareConfiguration: SoftwareConfiguration, hardwareConfigurations: [HardwareConfiguration]) {
                self.softwareConfiguration = softwareConfiguration
                self.hardwareConfigurations = hardwareConfigurations
            }

            init(robotSwconf: JobOrder_API.RobotAPIEntity.Swconf, robotAssets: [JobOrder_API.RobotAPIEntity.Asset]) {
                /// ソフトウェア情報
                let distribution = "\(robotSwconf.operatingSystem?.distribution ?? "") \(robotSwconf.operatingSystem?.distributionVersion ?? "")"
                let system = "\(robotSwconf.operatingSystem?.system ?? "") \(robotSwconf.operatingSystem?.systemVersion ?? "")"
                var installs = [SoftwareConfiguration.Installed]()
                if let softwares = robotSwconf.softwares {
                    for software in softwares {
                        let installed = SoftwareConfiguration.Installed(name: software.displayName ?? "", version: software.displayVersion ?? "")
                        installs.append(installed)
                    }
                }
                let softwareConfiguration = SoftwareConfiguration(system: system, distribution: distribution, installs: installs)

                /// ハードウェア情報
                var hardwareConfigurations = [HardwareConfiguration]()
                for asset in robotAssets {
                    let hardwareConfiguration = HardwareConfiguration(type: asset.type, model: asset.displayModel ?? "", maker: asset.displayMaker ?? "", serialNo: asset.displaySerial ?? "")
                    hardwareConfigurations.append(hardwareConfiguration)
                }

                self.init(softwareConfiguration: softwareConfiguration, hardwareConfigurations: hardwareConfigurations)
            }

            public static func == (lhs: System, rhs: System) -> Bool {
                return lhs.softwareConfiguration == rhs.softwareConfiguration &&
                    lhs.hardwareConfigurations.elementsEqual(rhs.hardwareConfigurations, by: { $0 == $1 })
            }

            public struct SoftwareConfiguration {
                public let system: String
                public let distribution: String
                public let installs: [Installed]

                public static func == (lhs: SoftwareConfiguration, rhs: SoftwareConfiguration) -> Bool {
                    return lhs.system == rhs.system &&
                        lhs.distribution == rhs.distribution &&
                        lhs.installs.elementsEqual(rhs.installs, by: { $0 == $1 })
                }

                public struct Installed {
                    public let name: String
                    public let version: String

                    public static func == (lhs: Installed, rhs: Installed) -> Bool {
                        return lhs.name == rhs.name &&
                            lhs.version == rhs.version
                    }
                }
            }

            public struct HardwareConfiguration {
                public let type: String
                public let model: String
                public let maker: String
                public let serialNo: String

                public static func == (lhs: HardwareConfiguration, rhs: HardwareConfiguration) -> Bool {
                    return lhs.type == rhs.type &&
                        lhs.model == rhs.model &&
                        lhs.maker == rhs.maker &&
                        lhs.serialNo == rhs.serialNo
                }
            }
        }

        /// ActionLibraryデータ
        public struct ActionLibrary {
            /// ID
            public let id: String
            /// 名前
            public let name: String
            /// 要求事項
            public let requirements: String?
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

            /// イニシャライザ
            /// - Parameters:
            /// 更新者
            ///   - id: ID
            ///   - name: 名前
            ///   - requirements: 要求事項
            ///   - imagePath: 画像パス
            ///   - overview: 概要
            ///   - remarks: 備考
            ///   - version: バージョン
            ///   - createTime: 作成日時
            ///   - creator: 作成者
            ///   - updateTime: 更新日時
            ///   - updator: 更新者
            public init(id: String, name: String, requirements: String?, imagePath: String?, overview: String?, remarks: String?, version: Int, createTime: Int, creator: String, updateTime: Int, updator: String) {
                self.id = id
                self.name = name
                self.requirements = requirements
                self.imagePath = imagePath
                self.overview = overview
                self.remarks = remarks
                self.version = version
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
            }

            /// エンティティ -> モデル変換
            /// - Parameter actionLibrary: ActionLibraryエンティティ
            init(_ actionLibrary: JobOrder_Data.ActionLibraryEntity) {
                self.id = actionLibrary.id
                self.name = actionLibrary.name
                self.requirements = actionLibrary.requirements
                self.imagePath = actionLibrary.imagePath
                self.overview = actionLibrary.overview
                self.remarks = actionLibrary.remarks
                self.version = actionLibrary.version
                self.createTime = actionLibrary.createTime
                self.creator = actionLibrary.creator
                self.updateTime = actionLibrary.updateTime
                self.updator = actionLibrary.updator
            }
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
            public let requirements: String?
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

            /// イニシャライザ
            /// - Parameters:
            /// 更新者
            ///   - id: ID
            ///   - name: 名前
            ///   - requirements: 要求事項
            ///   - imagePath: 画像パス
            ///   - overview: 概要
            ///   - remarks: 備考
            ///   - version: バージョン
            ///   - createTime: 作成日時
            ///   - creator: 作成者
            ///   - updateTime: 更新日時
            ///   - updator: 更新者
            public init(id: String, name: String, type: String, requirements: String?, imagePath: String?, overview: String?, remarks: String?, version: Int, createTime: Int, creator: String, updateTime: Int, updator: String) {
                self.id = id
                self.name = name
                self.type = type
                self.requirements = requirements
                self.imagePath = imagePath
                self.overview = overview
                self.remarks = remarks
                self.version = version
                self.createTime = createTime
                self.creator = creator
                self.updateTime = updateTime
                self.updator = updator
            }

            /// エンティティ -> モデル変換
            /// - Parameter aiLibrary: AILibraryエンティティ
            init(_ aiLibrary: JobOrder_Data.AILibraryEntity) {
                self.id = aiLibrary.id
                self.name = aiLibrary.name
                self.type = aiLibrary.type
                self.requirements = aiLibrary.requirements
                self.imagePath = aiLibrary.imagePath
                self.overview = aiLibrary.overview
                self.remarks = aiLibrary.remarks
                self.version = aiLibrary.version
                self.createTime = aiLibrary.createTime
                self.creator = aiLibrary.creator
                self.updateTime = aiLibrary.updateTime
                self.updator = aiLibrary.updator
            }
        }

        /// Robot画像
        public struct RobotImage: Codable {
            /// 画像データ
            public let data: Data?
        }
    }

    public struct InputTask: Codable {
        /// Jobデータ
        public var jobId: String
        /// Robotデータ
        public var robotIds: [String]

        public var start: String

        public var exit: String

        public var numberOfRuns: String

        public init(jobId: String, robotIds: [String], start: String, exit: String, numberOfRuns: String) {
            self.jobId = jobId
            self.robotIds = robotIds
            self.start = start
            self.exit = exit
            self.numberOfRuns = numberOfRuns
        }
    }
}
