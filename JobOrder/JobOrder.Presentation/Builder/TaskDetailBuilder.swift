//
//  TaskDetailBuilder.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

struct TaskDetailBuilder {

    struct TaskDetail {
        func build(vc: TaskDetailTaskInformationViewController) -> TaskDetailTaskInformationPresenter {
            return TaskDetailTaskInformationPresenter(dataUseCase: Builder().dataUseCase,
                                                      vc: vc)
        }
    }

    struct TaskDetailRobotSelection {
        func build(vc: TaskDetailRobotSelectionViewController, viewData: TaskDetailViewData) -> TaskDetailRobotSelectionPresenter {
            return TaskDetailRobotSelectionPresenter(dataUseCase: Builder().dataUseCase,
                                                     vc: vc,
                                                     viewData: viewData)
        }
    }

    struct TaskDetailRunHistory {
        func build(vc: TaskDetailRunHistoryViewController, jobData: MainViewData.Job) -> TaskDetailRunHistoryPresenter {
            return TaskDetailRunHistoryPresenter(dataUseCase: Builder().dataUseCase,
                                                 vc: vc,
                                                 jobData: jobData)
        }
        func build(vc: TaskDetailRunHistoryViewController, robotData: MainViewData.Robot) -> TaskDetailRunHistoryPresenter {
            return TaskDetailRunHistoryPresenter(dataUseCase: Builder().dataUseCase,
                                                 vc: vc,
                                                 robotData: robotData)
        }
    }

}
