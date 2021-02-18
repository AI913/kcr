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
    /// Authentication起動
    func launchAuthentication()
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
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!

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
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        createLeftBarItem()
        createRightBarItem()

        guard let viewControllers = self.viewControllers else {
            fatalError("ViewController is not found.")
        }

        for vc in viewControllers {
            _ = vc.view
        }
    }

    /// Note: SignIn のタイミングを Authentication から通知してもらう
    func viewWillAppearBySignIn() {
        if let presented = self.presentedViewController,
           type(of: presented) == AuthenticationNavigationController.self {
            let isDarkMode = self.traitCollection.userInterfaceStyle == .dark
            presenter?.setAnalyticsEndpointProfiles(displayAppearance: isDarkMode ? "Dark" : "Light" )
            presenter?.signIn()
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

    func launchAuthentication() {
        if self.presentedViewController is AuthenticationNavigationController { return }
        let vc = StoryboardScene.Authentication.initialScene.instantiate()
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
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        logo.image = Asset.Image.logoService.image
        let view = UIView(frame: logo.frame)
        view.addSubview(logo)
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: view), connectionStatusBarButtonItem]
    }

    private func createRightBarItem() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.text = presenter.rightBarLabel
        label.textAlignment = .right
        label.minimumScaleFactor = 0.5
        let view = UIView(frame: label.frame)
        view.addSubview(label)
        self.navigationItem.rightBarButtonItems = [settingsBarButtonItem, UIBarButtonItem(customView: view), jobEntryBarButtonItem]
        enableJobEntryButton(false)
    }

    private func enableJobEntryButton(_ isJob: Bool) {
        jobEntryBarButtonItem.isEnabled = isJob
        jobEntryBarButtonItem.tintColor = isJob ? nil : .clear
    }
}
