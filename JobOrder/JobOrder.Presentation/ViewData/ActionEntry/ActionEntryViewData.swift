//
//  ActionEntryViewData.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

struct ActionEntryViewData {

    static let point = 2
    var actionLibrary: ActionLibrary? /*= ActionLibrary(index: 0)*/
    var workbenchLibrary: WorkBenchLibrary? /*= WorkBenchLibrary(index: 0)*/
    var workLibrary: WorkLibrary?
    var srcTray: Tray?
    var destTray: [Tray] = []
    var works: [WorkAndTray] = []

    enum ActionLibrary: String, CaseIterable {
        case pAndp

        var name: String {
            switch self {
            case .pAndp:
                return "Pick And Place"
            }
        }

        var image: String {
            switch self {
            case .pAndp:
                return "xmark"
            }
        }

        init(index: Int) {
            self = ActionLibrary.allCases[index]
        }
    }

    enum WorkBenchLibrary: CaseIterable {
        case tray

        var name: String {
            switch self {
            case .tray:
                return "Tray"
            }
        }

        var image: String {
            switch self {
            case .tray:
                return "xmark"
            }
        }

        var cameraImage: ImageAsset {
            return ActionEntryViewData.point == 1 ?
                Asset.Image.point1TrayIndustrial :
                Asset.Image.point2TrayIndustrial
        }

        init(index: Int) {
            self = WorkBenchLibrary.allCases[index]
        }
    }

    enum WorkLibrary: CaseIterable {
        case industrialParts
        case stationery
        case spring

        var name: String {
            switch self {
            case .industrialParts: return L10n.ActionEntryViewData.WorkLibrary.Name.industrialParts
            case .stationery: return L10n.ActionEntryViewData.WorkLibrary.Name.stationery
            case .spring: return L10n.ActionEntryViewData.WorkLibrary.Name.spring
            }
        }

        var image: ImageAsset {
            switch self {
            case .industrialParts: return Asset.Image.iconIndustrialParts
            case .stationery: return Asset.Image.iconStationery
            case .spring: return Asset.Image.iconSpring
            }
        }

        var workbenchImage: ImageAsset? {
            switch self {
            case .industrialParts:
                return Asset.Image.point2TrayIndustrial
            case .stationery:
                return Asset.Image.point2TrayStationery
            default:
                return nil
            }
        }

        var workImage: ImageAsset? {
            switch self {
            case .industrialParts:
                return Asset.Image.industrialResult
            case .stationery:
                return Asset.Image.stationeryResult
            default:
                return nil
            }
        }

        init(index: Int) {
            self = WorkLibrary.allCases[index]
        }
    }

    struct WorkAndTray {
        let work: ActionEntryViewData.Work
        var tray: ActionEntryViewData.Tray?

        init(work: ActionEntryViewData.Work, tray: ActionEntryViewData.Tray?) {
            self.work = work
            self.tray = tray
        }
    }

    enum Tray: CaseIterable {
        case trayA
        case tray1
        case tray2
        case tray3

        static var count: Int {
            return ActionEntryViewData.point == 1 ? 2 : Tray.allCases.count
        }

        var name: String {
            switch self {
            case .trayA: return "Tray A"
            case .tray1: return "Tray 1"
            case .tray2: return "Tray 2"
            case .tray3: return "Tray 3"
            }
        }

        init(index: Int) {
            self = Tray.allCases[index]
        }
    }

    enum Work: CaseIterable, Equatable {
        // Industrial parts
        case clampPlate
        case valve
        case setCollar
        // Stationery
        case pen
        case tape
        case eraser

        var name: String {
            switch self {
            case .clampPlate: return "CLAMP_PLATE"
            // case .bolt: return "BOLT"
            // case .spring: return "SPRING"
            // case .rubberSeal: return "RUBBER_SEAL"
            case .valve: return "VALVE"
            // case .rubberStopper: return "RUBBER_STOPPER"
            case .setCollar: return "SET_COLLAR"
            case .pen: return "PEN"
            case .tape: return "TAPE"
            case .eraser: return "ERASER"
            // case .paste: return "GLUE_STICK"
            }
        }

        var parsent: String {
            switch self {
            case .clampPlate: return "100%"
            case .valve: return "100%"
            case .setCollar: return "98%"
            case .pen: return "94%"
            case .tape: return "99%"
            case .eraser: return "99%"
            }
        }

        var isIndustrialParts: Bool {
            switch self {
            case .clampPlate, .valve, .setCollar: return true
            default: return false
            }
        }

        var isStationery: Bool {
            switch self {
            case .pen, .tape, .eraser: return true
            default: return false
            }
        }

        init(index: Int) {
            self = Work.allCases[index]
        }
    }
}
