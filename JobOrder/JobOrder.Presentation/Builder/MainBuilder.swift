//
//  MainBuilder.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/25.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

struct MainBuilder {

    struct Main {
        func build(vc: MainTabBarController) -> MainPresenter {
            return MainPresenter(authUseCase: Builder().authUseCase,
                                 mqttUseCase: Builder().mqttUseCase,
                                 settingsUseCase: Builder().settingsUseCase,
                                 dataUseCase: Builder().dataUseCase,
                                 vc: vc)
        }
    }

    struct Dashboard {
        func build(vc: DashboardViewController) -> DashboardPresenter {
            return DashboardPresenter(mqttUseCase: Builder().mqttUseCase,
                                      dataUseCase: Builder().dataUseCase,
                                      vc: vc)
        }
    }

    struct JobList {
        func build(vc: JobListViewController) -> JobListPresenter {
            return JobListPresenter(useCase: Builder().dataUseCase,
                                    vc: vc)
        }
    }

    struct JobDetail {
        func build(vc: JobDetailViewController, viewData: MainViewData.Job) -> JobDetailPresenter {
            return JobDetailPresenter(useCase: Builder().dataUseCase,
                                      vc: vc,
                                      viewData: viewData)
        }
    }

    struct JobDetailWork {
        func build(vc: JobDetailWorkViewController, viewData: MainViewData.Job) -> JobDetailWorkPresenter {
            return JobDetailWorkPresenter(dataUseCase: Builder().dataUseCase,
                                          vc: vc,
                                          viewData: viewData)
        }
    }

    struct JobDetailFlow {
        func build(vc: JobDetailFlowViewController, viewData: MainViewData.Job) -> JobDetailFlowPresenter {
            return JobDetailFlowPresenter(vc: vc, viewData: viewData)
        }
    }

    struct JobDetailRemarks {
        func build(vc: JobDetailRemarksViewController, viewData: MainViewData.Job) -> JobDetailRemarksPresenter {
            return JobDetailRemarksPresenter(dataUseCase: Builder().dataUseCase,
                                             vc: vc,
                                             viewData: viewData)
        }
    }

    struct RobotList {
        func build(vc: RobotListViewController) -> RobotListPresenter {
            return RobotListPresenter(settingsUseCase: Builder().settingsUseCase,
                                      mqttUseCase: Builder().mqttUseCase,
                                      dataUseCase: Builder().dataUseCase,
                                      vc: vc)
        }
    }

    struct RobotDetail {
        func build(vc: RobotDetailViewController, viewData: MainViewData.Robot) -> RobotDetailPresenter {
            return RobotDetailPresenter(useCase: Builder().dataUseCase,
                                        vc: vc,
                                        viewData: viewData)
        }
    }

    struct RobotDetailRemarks {
        func build(vc: RobotDetailRemarksViewController, viewData: MainViewData.Robot) -> RobotDetailRemarksPresenter {
            return RobotDetailRemarksPresenter(useCase: Builder().dataUseCase,
                                               vc: vc,
                                               viewData: viewData)
        }
    }

    struct RobotDetailWork {
        func build(vc: RobotDetailWorkViewController, viewData: MainViewData.Robot) -> RobotDetailWorkPresenter {
            return RobotDetailWorkPresenter(dataUseCase: Builder().dataUseCase,
                                            vc: vc,
                                            viewData: viewData)
        }
    }

    struct RobotDetailSystem {
        func build(vc: RobotDetailSystemViewController, viewData: MainViewData.Robot) -> RobotDetailSystemPresenter {
            return RobotDetailSystemPresenter(mqttUseCase: Builder().mqttUseCase,
                                              dataUseCase: Builder().dataUseCase,
                                              vc: vc,
                                              viewData: viewData)
        }
    }

    struct RobotVideo {
        func build(vc: RobotVideoViewController) -> RobotVideoPresenter {
            return RobotVideoPresenter(useCase: Builder().videoStreamingUseCase,
                                       vc: vc)
        }
    }

    struct Settings {
        func build(vc: SettingsViewController) -> SettingsPresenter {
            return SettingsPresenter(useCase: Builder().settingsUseCase,
                                     authUseCase: Builder().authUseCase,
                                     mqttUseCase: Builder().mqttUseCase,
                                     dataUseCase: Builder().dataUseCase,
                                     vc: vc)
        }
    }

    struct AboutApp {
        func build(vc: AboutAppViewController) -> AboutAppPresenter {
            return AboutAppPresenter(useCase: Builder().settingsUseCase,
                                     vc: vc)
        }
    }
}
