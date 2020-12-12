//
//  RobotDetailSystemViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import Charts

/// RobotDetailSystemViewControllerProtocol
/// @mockable
protocol RobotDetailSystemViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// テーブルを更新
    func reloadTable()
    /// ハードウェア構成情報のアコーディオン開閉
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func toggleExtensionTable(in: RobotDetailSystemPresenter.Dataset, section: Int)
}

class RobotDetailSystemViewController: RobotDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var softwareConfigurationTableView: UITableView!
    @IBOutlet weak var softwareConfigurationTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hardwareConfigurationTableView: UITableView!
    @IBOutlet weak var hardwareConfigurationTableViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    var presenter: RobotDetailSystemPresenterProtocol!
    private var containerWithoutTableViewHeight: CGFloat = 0
    private var extendedHardwareConfiguration = [Bool]()

    override func inject(viewData: MainViewData.Robot) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.RobotDetailSystem().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()

        // 可変なテーブル以外の合計サイズを取得
        if let containerViewHeight = self.view.subviews.first?.frame.height {
            containerWithoutTableViewHeight = containerViewHeight - softwareConfigurationTableView.frame.height - hardwareConfigurationTableView.frame.height
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // テーブルを含めたサイズを設定
        softwareConfigurationTableView.layoutIfNeeded()
        softwareConfigurationTableViewHeight.constant = softwareConfigurationTableView.contentSize.height
        hardwareConfigurationTableView.layoutIfNeeded()
        hardwareConfigurationTableViewHeight.constant = hardwareConfigurationTableView.contentSize.height

        let height =
            containerWithoutTableViewHeight +
            softwareConfigurationTableView.contentSize.height +
            hardwareConfigurationTableView.contentSize.height
        preferredContentSize.height = max(height, initialHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let identifier = RobotDetailSystemDetailTableViewHeader().identifier
        let xib = UINib(nibName: identifier, bundle: Bundle(for: RobotDetailSystemDetailTableViewHeader.self))
        softwareConfigurationTableView.register(xib, forHeaderFooterViewReuseIdentifier: identifier)
        hardwareConfigurationTableView.register(xib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension RobotDetailSystemViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.presenter?.numberOfSections(in: dataset(by: tableView)) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(hardwareConfigurationTableView), section < extendedHardwareConfiguration.count {
            if !extendedHardwareConfiguration[section] {
                return 0
            }
        }
        return self.presenter?.numberOfRowsInSection(in: dataset(by: tableView), section: section) ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let (_, titleValue) = self.presenter?.title(in: dataset(by: tableView), section: section) {
            if titleValue == nil {
                return noTitleValueCellHeight
            }
        }
        return standardCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        standardCellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RobotDetailSystemDetailTableViewCell().identifier, for: indexPath)
        if let detailCell = cell as? RobotDetailSystemDetailTableViewCell {
            detailCell.presenter = self.presenter
            detailCell.dataset = dataset(by: tableView)
            detailCell.setRow(indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: RobotDetailSystemDetailTableViewHeader().identifier)
        if let header = cell as? RobotDetailSystemDetailTableViewHeader {
            header.presenter = self.presenter
            header.dataset = dataset(by: tableView)
            header.clipsToBounds = true
            if tableView.isEqual(hardwareConfigurationTableView), section < self.extendedHardwareConfiguration.count {
                header.setRow(section, accessory: presenter.accessory(in: extendedHardwareConfiguration[section]), tapable: true)
            } else {
                header.setRow(section)
            }
        }
        return cell
    }
}

// MARK: - Interface Function
extension RobotDetailSystemViewController: RobotDetailSystemViewControllerProtocol {

    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    /// テーブルを更新
    func reloadTable() {
        extendedHardwareConfiguration.removeAll()
        if let num = self.presenter?.numberOfSections(in: dataset(by: hardwareConfigurationTableView)) {
            extendedHardwareConfiguration = Array(repeating: false, count: num)
        }

        softwareConfigurationTableView.reloadData()
        hardwareConfigurationTableView.reloadData()

        self.view.setNeedsLayout()
    }

    /// ハードウェア構成情報のアコーディオン開閉
    /// - Parameters:
    ///   - in: 設定情報種別
    ///   - section: セクションIndex
    func toggleExtensionTable(in config: RobotDetailSystemPresenter.Dataset, section: Int) {
        guard config == .hardware else { return }
        guard section < extendedHardwareConfiguration.count else { return }

        extendedHardwareConfiguration[section] = !extendedHardwareConfiguration[section]
        hardwareConfigurationTableView.reloadSections(IndexSet([section]), with: .automatic)

        self.view.setNeedsLayout()
    }

}

// MARK: - Private Function
extension RobotDetailSystemViewController {
    private func dataset(by tableView: UITableView) -> RobotDetailSystemPresenter.Dataset {
        tableView.isEqual(self.softwareConfigurationTableView) ? .software : .hardware
    }

    private var standardCellHeight: CGFloat {
        49.5
    }

    private var noTitleValueCellHeight: CGFloat {
        standardCellHeight / 2.0
    }
}
