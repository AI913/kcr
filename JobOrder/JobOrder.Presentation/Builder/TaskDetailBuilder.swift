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
        func build(vc: TaskDetailViewController) -> TaskDetailPresenter {
            return TaskDetailPresenter(dataUseCase: Builder().dataUseCase,
                                       vc: vc)
        }
    }

    struct TaskDetailRobotSelection {
        func build(vc: TaskDetailRobotSelectionViewController
                   //,viewData: TaskDetailRobotSelectionViewData.Command
        ) -> TaskDetailRobotSelectionPresenter {
            return TaskDetailRobotSelectionPresenter(dataUseCase: Builder().dataUseCase,
                                                     vc: vc
                                                     //,viewData: viewData
            )
        }
    }
}
