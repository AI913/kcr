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
/// OrderEntryConfirmPresenterProtocol
/// @mockable
protocol OrderEntryConfirmPresenterProtocol {
    /// OrderEntryのViewData
    var data: OrderEntryViewData { get }
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
/// OrderEntryConfirmPresenter
class OrderEntryConfirmPresenter {

    /// MQTTUseCaseProtocol
    private let mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol
    /// DataManageUseCaseProtocol
    private let dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol
    /// OrderEntryConfirmViewControllerProtocol
    private let vc: OrderEntryConfirmViewControllerProtocol
    /// OrderEntryのViewData
    var data: OrderEntryViewData
    /// A type-erasing cancellable objects that executes a provided closure when canceled.
    private var cancellables: Set<AnyCancellable> = []
    /// DataManageModel.Output.Task
    var task: JobOrder_Domain.DataManageModel.Output.Task?

    /// イニシャライザ
    /// - Parameters:
    ///   - mqttUseCase: MQTTUseCaseProtocol
    ///   - dataUseCase: DataManageUseCaseProtocol
    ///   - vc: OrderEntryConfirmViewControllerProtocol
    ///   - viewData: OrderEntryViewData
    required init(mqttUseCase: JobOrder_Domain.MQTTUseCaseProtocol,
                  dataUseCase: JobOrder_Domain.DataManageUseCaseProtocol,
                  vc: OrderEntryConfirmViewControllerProtocol,
                  viewData: OrderEntryViewData) {
        self.mqttUseCase = mqttUseCase
        self.dataUseCase = dataUseCase
        self.vc = vc
        self.data = viewData
        subscribeUseCaseProcessing()
    }
}

// MARK: - Protocol Function
extension OrderEntryConfirmPresenter: OrderEntryConfirmPresenterProtocol {

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
        let inputTask = DataManageModel.InputTask(jobId: data.form.jobId!, robotIds: data.form.robotIds!, start: self.startCondition!, exit: self.exitCondition!, numberOfRuns: self.numberOfRuns)
        dataUseCase.postTask(data: inputTask)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.vc.showErrorAlert(error)
                }
            }, receiveValue: { response in
                Logger.debug(target: self, "\(String(describing: response))")
                self.task = response
                self.vc.transitionToCompleteScreen()
            }).store(in: &cancellables)
    }
}

// MARK: - Private Function
extension OrderEntryConfirmPresenter {

    private func subscribeUseCaseProcessing() {
        // 通信中はキー無効
        // mqttUseCase.$processing.sink { response in
        mqttUseCase.processingPublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                Logger.debug(target: self, "MQTT: \(response)")
                self.vc.changedProcessing(response)
            }.store(in: &cancellables)
    }

    private func createJobInputModel() -> JobOrder_Domain.MQTTModel.Input.CreateJob? {
        var model = JobOrder_Domain.MQTTModel.Input.CreateJob()
        model.jobId = data.form.jobId
        model.robotIds = data.form.robotIds
        model.startCondition = JobOrder_Domain.MQTTModel.Input.CreateJob.StartCondition(key: data.form.startCondition?.displayName)
        model.exitCondition = JobOrder_Domain.MQTTModel.Input.CreateJob.ExitCondition(key: data.form.exitCondition?.displayName)
        model.numberOfRuns = data.form.numberOfRuns
        model.remarks = data.form.remarks
        return model
    }
}
