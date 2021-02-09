//
//  JobEntryBuilder.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2021/01/19.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation

struct JobEntryBuilder {

    struct GeneralInfo {
        func build(vc: JobEntryGeneralInfoViewController) -> JobEntryGeneralInfoPresenter {
            return JobEntryGeneralInfoPresenter(useCase: Builder().dataUseCase,
                                                vc: vc)
        }
    }

//    struct ActionLibrarySelection {
//        func build(vc: JobEntrySearchViewController, viewData: JobEntryViewData) -> JobEntrySearchPresenter {
//            return JobEntrySearchPresenter(dataUseCase: Builder().dataUseCase,
//                                                     vc: vc,
//                                                     viewData: viewData)
//        }
//    }
}
