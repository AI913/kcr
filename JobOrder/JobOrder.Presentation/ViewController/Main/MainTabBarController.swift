//
//  MainTabBarController.swift
//  JobOrder.Presentation
//
//  Created by Kento Tatsumi on 2020/03/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// MainTabBarControllerProtocol
/// @mockable
protocol MainTabBarControllerProtocol: class {
    /// アラート表示
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    func showAlert(_ title: String, _ message: String)
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// PasswordAuthentication起動
    func launchPasswordAuthentication()
    /// ConnectionStatusボタンを更新
    /// - Parameter color: 表示カラー
    func updateConnectionStatusButton(color: UIColor?)
    /// JobEntryを起動
    func launchJobEntry()
}

class MainTabBarController: UITabBarController {

    // MARK: - IBOutlet
    @IBOutlet weak var connectionStatusBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var jobEntryBarButtonItem: UIBarButtonItem!

    private enum Tab: String {
        case Dashboard = "Dashboard"
        case Robot = "Robot"
        case Job = "Job"
    }

    // MARK: - Variable
    var presenter: MainPresenterProtocol!

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.Main().build(vc: self)

        let isDarkMode = self.traitCollection.userInterfaceStyle == .dark
        presenter?.setAnalyticsEndpointProfiles(displayAppearance: isDarkMode ? "Dark" : "Light" )
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        createLeftBarItem()

        guard let viewControllers = self.viewControllers else {
            fatalError("ViewController is not found.")
        }

        for vc in viewControllers {
            _ = vc.view
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }

    func viewWillAppearByBiometricsAuthentication() {
        /// 生体認証時はSignIn通知が来ないため、認証画面からイベントを受け取ってSignIn時の処理を行う
        if let presented = self.presentedViewController,
           type(of: presented) == PasswordAuthenticationNavigationController.self {
            presenter?.signInByBiometricsAuthentication()
        }
    }
}

// MARK: - Action
extension MainTabBarController {

    @IBAction private func selectorConnectionStatusBarButtonItem(_ sender: UIBarButtonItem) {
        presenter?.tapConnectionStatusButton()
    }

    @IBAction func jobEntryButtonTapped(_ sender: Any) {
        presenter?.tapAddButton()
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let isJob = Tab(rawValue: tabBar.selectedItem?.title ?? "") == .Job
        enableJobEntryButton(isJob)
    }
}

// MARK: - Interface Function
extension MainTabBarController: MainTabBarControllerProtocol {

    func showAlert(_ title: String, _ message: String) {
        presentAlert(title, message)
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func launchPasswordAuthentication() {
        if self.presentedViewController is PasswordAuthenticationNavigationController { return }
        let vc = StoryboardScene.PasswordAuthentication.initialScene.instantiate()
        self.present(vc, animated: true, completion: nil)
        self.selectedIndex = 0
    }

    func updateConnectionStatusButton(color: UIColor?) {
        connectionStatusBarButtonItem.tintColor = color
    }

    func launchJobEntry() {
        let vc = StoryboardScene.JobEntry.initialScene.instantiate()
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Private Function
extension MainTabBarController {

    private func createLeftBarItem() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 30)
        let view = UIView(frame: rect)
        let logo = UIImageView(frame: rect)
        logo.image = Asset.Image._01BrandsymbolColor.image
        view.addSubview(logo)
        let item = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItems = [item, connectionStatusBarButtonItem]
        enableJobEntryButton(false)
    }

    private func enableJobEntryButton(_ isJob: Bool) {
        jobEntryBarButtonItem.isEnabled = isJob
        if isJob {
            jobEntryBarButtonItem.tintColor = nil
        } else {
            jobEntryBarButtonItem.tintColor = UIColor.clear
        }
    }
}
