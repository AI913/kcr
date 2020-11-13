//
//  RobotDetailSystemPresenterTests.swift
//  JobOrder.PresentationTests
//
//  Created by Yu Suzuki on 2020/08/18.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import Combine
@testable import JobOrder_Presentation
@testable import JobOrder_Domain

class RobotDetailSystemPresenterTests: XCTestCase {

    private let ms1000 = 1.0
    private let stub = PresentationTestsStub()
    private let vc = RobotDetailSystemViewControllerProtocolMock()
    private let mqtt = JobOrder_Domain.MQTTUseCaseProtocolMock()
    private let data = JobOrder_Domain.DataManageUseCaseProtocolMock()
    private let viewData = MainViewData.Robot()
    private lazy var presenter = RobotDetailSystemPresenter(mqttUseCase: mqtt,
                                                            dataUseCase: data,
                                                            vc: vc,
                                                            viewData: viewData)
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    func test_viewWillAppear() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        presenter.data.id = param

        data.robotSystemHandler = { id in
            return Future<DataManageModel.Output.System, Error> { promise in
                promise(.success(self.stub.system))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }
        presenter.viewWillAppear()
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssert(presenter.detailSystem! == self.stub.system, "正しい値が取得できていない")
    }

    func test_viewWillAppearError() {
        let param = "test"
        let handlerExpectation = expectation(description: "handler")
        let completionExpectation = expectation(description: "completion")
        completionExpectation.isInverted = true
        presenter.data.id = param

        data.robotSystemHandler = { id in
            return Future<DataManageModel.Output.System, Error> { promise in
                let error = NSError(domain: "Error", code: -1, userInfo: nil)
                promise(.failure(error))
                handlerExpectation.fulfill()
            }.eraseToAnyPublisher()
        }
        presenter.viewWillAppear()
        wait(for: [handlerExpectation, completionExpectation], timeout: ms1000)
        XCTAssertNil(presenter.detailSystem, "正しい値が取得できてはいけない")
    }

    func test_numberOfSections() {
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.detailSystem = nil
            XCTAssertEqual(presenter.numberOfSections(in: .software), 0, "正しい値が取得できていない")
            XCTAssertEqual(presenter.numberOfSections(in: .hardware), 0, "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "detailSystemが存在する場合") { _ in
            presenter.detailSystem = self.stub.system
            XCTAssertEqual(presenter.numberOfSections(in: .software), 3, "正しい値が取得できていない")
            XCTAssertEqual(presenter.numberOfSections(in: .hardware), self.stub.system.hardwareConfigurations.count, "正しい値が取得できていない")
        }
    }

    func test_numberOfRowsInSection() {
        let installedSoftwareSection = 2
        let firstHardwareSection = 0
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.detailSystem = nil
            XCTAssertEqual(presenter.numberOfRowsInSection(in: .software, section: installedSoftwareSection), 0, "正しい値が取得できていない")
            XCTAssertEqual(presenter.numberOfRowsInSection(in: .hardware, section: firstHardwareSection), 0, "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "detailSystemが存在する場合") { _ in
            presenter.detailSystem = self.stub.system
            XCTAssertEqual(presenter.numberOfRowsInSection(in: .software, section: installedSoftwareSection), self.stub.system.softwareConfiguration.installs.count, "正しい値が取得できていない")
            XCTAssertEqual(presenter.numberOfRowsInSection(in: .hardware, section: firstHardwareSection), self.stub.system.hardwareConfigurations.count, "正しい値が取得できていない")
        }
    }

    func test_title() {
        let firstSoftwareSection = 0
        let installedSoftwareSection = 2
        let firstHardwareSection = 0
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.detailSystem = nil
            XCTAssertTrue(presenter.title(in: .software, section: firstSoftwareSection) == (viewData.detailSystem.softwareSystemTitle, nil), "正しい値が取得できていない")
            XCTAssertTrue(presenter.title(in: .software, section: installedSoftwareSection) == (viewData.detailSystem.softwareInstalledsoftwareTitle, nil), "正しい値が取得できていない")
            XCTAssertTrue(presenter.title(in: .hardware, section: firstHardwareSection) == ("", nil), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "detailSystemが存在する場合") { _ in
            presenter.detailSystem = self.stub.system
            XCTAssertTrue(presenter.title(in: .software, section: firstSoftwareSection) == (viewData.detailSystem.softwareSystemTitle, self.stub.system.softwareConfiguration.system), "正しい値が取得できていない")
            XCTAssertTrue(presenter.title(in: .software, section: installedSoftwareSection) == (viewData.detailSystem.softwareInstalledsoftwareTitle, nil), "正しい値が取得できていない")
            XCTAssertTrue(presenter.title(in: .hardware, section: firstHardwareSection) == (self.stub.system.hardwareConfigurations[firstHardwareSection].type, self.stub.system.hardwareConfigurations[firstHardwareSection].model), "正しい値が取得できていない")
        }
    }

    func test_detail() {
        let installedSoftwareSection = 2
        let firstSoftwareInstalledRow = 0
        let firstHardwareSection = 0
        let firstHardwareRow = 0
        XCTContext.runActivity(named: "未設定の場合") { _ in
            presenter.detailSystem = nil
            XCTAssertTrue(presenter.detail(in: .software, indexPath: IndexPath(row: firstSoftwareInstalledRow, section: installedSoftwareSection)) == ("", ""), "正しい値が取得できていない")
            XCTAssertTrue(presenter.detail(in: .hardware, indexPath: IndexPath(row: firstHardwareRow, section: firstHardwareSection)) == ("", ""), "正しい値が取得できていない")
        }
        XCTContext.runActivity(named: "detailSystemが存在する場合") { _ in
            presenter.detailSystem = self.stub.system
            XCTAssertTrue(presenter.detail(in: .software, indexPath: IndexPath(row: firstSoftwareInstalledRow, section: installedSoftwareSection)) == (self.stub.system.softwareConfiguration.installs[firstSoftwareInstalledRow].name, self.stub.system.softwareConfiguration.installs[firstSoftwareInstalledRow].version), "正しい値が取得できていない")
            XCTAssertTrue(presenter.detail(in: .hardware, indexPath: IndexPath(row: firstHardwareRow, section: firstHardwareSection)) == (viewData.detailSystem.hardwareMakerTitle, self.stub.system.hardwareConfigurations[firstHardwareRow].maker), "正しい値が取得できていない")
        }
    }

    func test_tapHeader() {
        let someSection = 0

        presenter.tapHeader(in: .software, section: someSection)
        XCTAssertEqual(vc.toggleExtensionTableCallCount, 1, "ViewControllerのメソッドが呼ばれない")

        presenter.tapHeader(in: .hardware, section: someSection)
        XCTAssertEqual(vc.toggleExtensionTableCallCount, 2, "ViewControllerのメソッドが呼ばれない")
    }

    func test_accessory() {
        XCTAssertEqual(presenter.accessory(in: true), viewData.detailSystem.accessoryOpened, "開いた記号ではない")
        XCTAssertEqual(presenter.accessory(in: false), viewData.detailSystem.accessoryClosed, "閉じた記号ではない")
    }
}
