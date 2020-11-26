//
//  JobDetailFlowPresenter.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

// MARK: - Interface
/// JobDetailFlowPresenterProtocol
/// @mockable
protocol JobDetailFlowPresenterProtocol {
    /// ViewData
    var data: MainViewData.Job { get }
    /// View表示開始
    func viewWillAppear()
}

// MARK: - Implementation
/// JobDetailFlowPresenter
class JobDetailFlowPresenter {
    /// JobDetailWorkViewControllerProtocol
    private let vc: JobDetailFlowViewControllerProtocol
    /// ViewData
    var data: MainViewData.Job

    required init(vc: JobDetailFlowViewControllerProtocol, viewData: MainViewData.Job) {
        self.vc = vc
        self.data = viewData
    }
}

// MARK: - Protocol Function
extension JobDetailFlowPresenter: JobDetailFlowPresenterProtocol {

    /// View表示開始
    func viewWillAppear() {
    }

}
