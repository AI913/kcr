//
//  StartupViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2021/02/04.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

/// StartupViewControllerProtocol
/// @mockable
protocol StartupViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// SpaceView表示
    func showSpaceView()
    /// Main起動
    func launchMain()
}

class StartupViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var spaceTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    // MARK: - Variable
    var presenter: StartupPresenterProtocol!

    private var processing: Bool! {
        didSet {
            processing ? indicator.startAnimating() : indicator.stopAnimating()
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = StartupBuilder.Startup().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
}

// MARK: - View Controller Event
extension StartupViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Action
extension StartupViewController {

    @IBAction private func touchUpInsideNextButton(_ sender: UIButton) {
        presenter?.tapNextButton()
    }

    @IBAction private func editingChangedSpaceTextField(_ sender: UITextField) {
        presenter?.changedSpaceTextField(sender.text)
        nextButton?.isEnabled = presenter?.isEnabledNextButton ?? false
    }

    @IBAction private func didEndOnExitSpaceTextField(_ sender: UITextField) {
        sender.endEditing(true)
    }
}

// MARK: - Interface Function
extension StartupViewController: StartupViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func showSpaceView() {
        spaceView?.isHidden = false
    }

    func launchMain() {
        self.perform(segue: StoryboardSegue.Startup.launchMain, sender: nil)
    }
}
