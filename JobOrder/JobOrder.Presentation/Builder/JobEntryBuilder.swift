//
//  JobEntryBuilder.swift
//  JobOrder.Presentation
//
//  Created by frontarc on 2021/01/19.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation

struct JobEntryBuilder {

    struct GeneralInformationForm {
        func build(vc: JobEntryGeneralInformationFormViewController, viewData: JobEntryViewData) -> JobEntryGeneralInformationFormPresenter {
            return JobEntryGeneralInformationFormPresenter(useCase: Builder().dataUseCase,
                                                           vc: vc, viewData: viewData)
        }
    }

}
