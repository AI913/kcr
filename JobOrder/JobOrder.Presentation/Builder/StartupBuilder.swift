//
//  StartupBuilder.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2021/02/04.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation

struct StartupBuilder {

    struct Startup {
        func build(vc: StartupViewController) -> StartupPresenter {
            return StartupPresenter(authUseCase: Builder().authUseCase,
                                    settingsUseCase: Builder().settingsUseCase,
                                    vc: vc)
        }
    }
}
