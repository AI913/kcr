//
//  ViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/07/10.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

// MARK: - Interface
/// RobotVideoViewControllerProtocol
/// @mockable
protocol RobotVideoViewControllerProtocol: class {
    /// ビデオViewを貼り付け
    /// - Parameter view: ビデオView
    func addVideoView(view: UIView?)
    /// ビデオViewを削除
    /// - Parameter view: ビデオView
    func removeVideoView(view: UIView?)
    /// インジケータ表示
    /// - Parameter isShown: 表示可否
    func showIndicator(isShown: Bool)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
}

// MARK: - Implementation
class RobotVideoViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    // MARK: - Variable
    var presenter: RobotVideoPresenterProtocol!

    private var processing: Bool! {
        didSet {
            connectButton?.isHidden = processing
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.RobotVideo().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        presenter?.setContainerView(view: self.view)
    }
}

// MARK: - Action
extension RobotVideoViewController {

    @IBAction private func touchUpInsideConnectButton(_ sender: UIButton) {
        presenter?.tapConnectButton()
    }
}

// MARK: - Interface Function
extension RobotVideoViewController: RobotVideoViewControllerProtocol {

    func addVideoView(view: UIView?) {
        guard let view = view else { return }
        embedView(view, into: self.view)
        self.view.sendSubviewToBack(view)
    }

    func removeVideoView(view: UIView?) {
        view?.removeFromSuperview()
    }

    func showIndicator(isShown: Bool) {
        if isShown {
            indicator?.startAnimating()
        } else {
            indicator?.stopAnimating()
        }
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }
}

// MARK: - Private Function
extension RobotVideoViewController {

    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view": view]))
        containerView.layoutIfNeeded()
    }
}

// MARK: - Implement UINavigationControllerDelegate
extension RobotVideoViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController != self {
            presenter?.tapBackButton()
        }
    }
}
