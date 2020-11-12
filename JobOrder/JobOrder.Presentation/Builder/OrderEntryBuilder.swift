//
//  OrderEntryBuilder.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

struct OrderEntryBuilder {

    struct JobSelection {
        func build(vc: OrderEntryJobSelectionViewController, viewData: OrderEntryViewData) -> OrderEntryJobSelectionPresenter {
            return OrderEntryJobSelectionPresenter(useCase: Builder().dataUseCase,
                                                   vc: vc,
                                                   viewData: viewData)
        }
    }

    struct RobotSelection {
        func build(vc: OrderEntryRobotSelectionViewController, viewData: OrderEntryViewData) -> OrderEntryRobotSelectionPresenter {
            return OrderEntryRobotSelectionPresenter(useCase: Builder().dataUseCase,
                                                     vc: vc,
                                                     viewData: viewData)
        }
    }

    struct ConfigurationForm {
        func build(vc: OrderEntryConfigurationFormViewController, viewData: OrderEntryViewData) -> OrderEntryConfigurationFormPresenter {
            return OrderEntryConfigurationFormPresenter(vc: vc,
                                                        viewData: viewData)
        }
    }

    struct Confirm {
        func build(vc: OrderEntryConfirmViewController, viewData: OrderEntryViewData) -> OrderEntryConfirmPresenter {
            return OrderEntryConfirmPresenter(mqttUseCase: Builder().mqttUseCase,
                                              dataUseCase: Builder().dataUseCase,
                                              vc: vc,
                                              viewData: viewData)
        }
    }
}
