//
//  JobEntryConfigurationViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/24.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobEntryConfigurationViewControllerProtocol
/// @mockable
protocol JobEntryConfigurationViewControllerProtocol: class {
    /// ページ変更
    /// - Parameter index: インデックス
    func pageChanged(index: Int)
}

class JobEntryConfigurationViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBAction func infoButtonTapped(_ sender: Any) {
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        pageVc?.changePage(index: sender.selectedSegmentIndex)
    }
    
    var pageVc: JobEntryConfigurationPageViewController?

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
//        setSwipeBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        containerViewHeight?.constant = container.preferredContentSize.height
    }
}

// MARK: - Interface Function
extension JobEntryConfigurationViewController: JobEntryConfigurationViewControllerProtocol {

    /// ページ変更
    /// - Parameter index: インデックス
    func pageChanged(index: Int) {
        segmentedControl?.selectedSegmentIndex = index
    }
}

//// MARK: - Private Function
//extension JobEntryConfigurationViewController {
//
//    private func addBlurView() {
//
//        guard let navigationController = self.navigationController else { return }
//
//        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
//        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
//        visualEffectView.alpha = 0.9
//        navigationController.view.addSubview(visualEffectView)
//        visualEffectView.topAnchor.constraint(equalTo: navigationController.view.topAnchor).isActive = true
//        visualEffectView.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor).isActive = true
//        visualEffectView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor).isActive = true
//        visualEffectView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor).isActive = true
//
//        let label = UILabel()
//        label.text = L10n.selectAJobFromTheList
//        label.font = .systemFont(ofSize: 24)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        visualEffectView.contentView.addSubview(label)
//        label.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor).isActive = true
//    }
//}

