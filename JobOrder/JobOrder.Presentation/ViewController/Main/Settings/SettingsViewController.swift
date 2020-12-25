//
//  SettingsViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/25.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit
import SkeletonView

/// SettingsViewControllerProtocol
/// @mockable
protocol SettingsViewControllerProtocol: class {
    /// クラス名
    var className: String { get }
    /// 戻る
    func back()
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// AboutApp画面へ遷移
    func transitionToAboutAppScreen()
    /// RobotVideo画面へ遷移
    func transitionToRobotVideoScreen()
    /// テーブルを更新
    func reloadTable()
}

class SettingsViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var accountidentifierLabel: UILabel!
    @IBOutlet weak var accountRemarksLabel: UILabel!
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    // MARK: - Variable
    var presenter: SettingsPresenterProtocol!

    private var processing: Bool! {
        didSet {
            self.menuTable?.allowsSelection = !self.processing
            if self.processing {
                indicator?.startAnimating()
            } else {
                indicator?.stopAnimating()
            }
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.Settings().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set account information.
        self.accountRemarksLabel?.text = presenter?.username
        self.accountidentifierLabel?.showAnimatedGradientSkeleton()

        presenter?.email {
            self.accountidentifierLabel?.hideSkeleton()
            self.accountidentifierLabel?.text = self.toLabelText($0)
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter?.titleForHeaderInSection(section: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return presenter?.titleForFooterInSection(section: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRowsInSection(section: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = presenter?.reusableIdentifier(indexPath: indexPath) else {
            return UITableViewCell()
        }

        let _cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        guard let cell = _cell as? SettingsMenuTableViewCell else {
            return _cell
        }
        cell.inject(presenter: presenter, viewData: presenter.getRow(indexPath: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectRow(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Interface Function
extension SettingsViewController: SettingsViewControllerProtocol {

    var className: String {
        String(describing: type(of: self))
    }

    func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToAboutAppScreen() {
        self.perform(segue: StoryboardSegue.Main.showAboutApp)
    }

    func transitionToRobotVideoScreen() {
        self.perform(segue: StoryboardSegue.Main.showRobotVideo)
    }

    func reloadTable() {
        self.menuTable?.reloadData()
    }
}
