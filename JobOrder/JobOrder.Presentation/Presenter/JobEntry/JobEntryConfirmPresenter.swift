//
//  OrderEntryConfirmPresenter.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/14.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import Combine
import JobOrder_Domain
import JobOrder_Utility

// MARK: - Interface
/// JobEntryConfirmPresenterProtocol
/// @mockable
protocol JobEntryConfirmPresenterProtocol {
    /// JobEntryのViewData
    var data: JobEntryViewData { get }
    /// Jobの表示名
    var job: String? { get }
    /// Robotの表示名
    var robots: String? { get }
    /// 稼働開始条件
    var startCondition: String? { get }
    /// 稼働終了条件
    var exitCondition: String? { get }
    /// 稼働回数
    var numberOfRuns: String { get }
    /// 備考
    var remarks: String? { get }
    /// Sendボタンをタップ
    func tapSendButton()
}

// MARK: - Implementation
/// JobEntryConfirmPresenter
class JobEntryConfirmPresenter {
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// OrderEntryConfirmViewControllerProtocol
    private let vc: JobEntryConfirmViewControllerProtocol
    /// OrderEntryのViewData
    var data: JobEntryViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []

    /// イニシャライザ
    /// - Parameters:
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: JobEntryConfirmViewControllerProtocol
    ///   - viewData: JobEntryViewData
    required init(dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: JobEntryConfirmViewControllerProtocol,
                  viewData: JobEntryViewData) {
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension JobEntryConfirmPresenter: JobEntryConfirmPresenterProtocol {

    /// Jobの表示名
    var job: String? {
        dataUseCase.jobs?.first(where: { $0.id == data.form.jobId })?.name
    }

    /// Robotの表示名
    var robots: String? {
        guard let ids = data.form.robotIds else { return nil }
        return dataUseCase.robots?.filter { ids.contains($0.id) }.map { $0.name ?? "N/A" }.sorted().joined(separator: "\n")
    }

    /// 稼働開始条件
    var startCondition: String? {
        data.form.startCondition?.displayName
    }

    /// 稼働終了条件
    var exitCondition: String? {
        data.form.exitCondition?.displayName
    }

    /// 稼働回数
    var numberOfRuns: String {
        return String(data.form.numberOfRuns)
    }

    /// 備考
    var remarks: String? {
        data.form.remarks
    }

    /// Sendボタンをタップ
    func tapSendButton() {

        guard let model = createJobInputModel(), let robotIds = data.form.robotIds else { return }

        dataUseCase.postTask(postData: model)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.vc.transitionToCompleteScreen()
            }).store(in: &cancellables)
    }
}

// MARK: - Private Function
extension JobEntryConfirmPresenter {

    private func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        //         mqttUseCase.$processing.sink { response in
        dataUseCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "UseCase: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    private func createJobInputModel() -> JobOrder_Domain.DataManageModel.Input.Task? {
        guard let jobid = data.form.jobId, let robotIds = data.form.robotIds,
              let start = data.form.startCondition, let exit = data.form.exitCondition else { return nil }
        let model = JobOrder_Domain.DataManageModel.Input.Task(jobId: jobid,
                                                               robotIds: robotIds,
                                                               start: DataManageModel.Input.Task.Start(start.rawValue),
                                                               exit: DataManageModel.Input.Task.Exit(
                                                                condition: exit.rawValue,
                                                                option: DataManageModel.Input.Task.Exit.Option(data.form.numberOfRuns)))
        return model
    }
}
