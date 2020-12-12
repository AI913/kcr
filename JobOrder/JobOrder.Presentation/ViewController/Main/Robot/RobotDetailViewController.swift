//
//  RobotDetailViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// RobotDetailViewControllerProtocol
/// @mockable
protocol RobotDetailViewControllerProtocol: class {
    /// ActionSheetを表示
    /// - Parameter button: 起点とするボタン
    func showActionSheet(_ button: UIBarButtonItem)
    func pageChanged(index: Int)
    /// OrderEntry画面へ遷移
    func launchOrderEntry()
}

class RobotDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var displayNameValueLabel: UILabel!
    @IBOutlet weak var robotImageView: UIImageView!
    @IBOutlet weak var robotTypeValueLabel: UILabel!
    @IBOutlet weak var serialValueLabel: UILabel!
    @IBOutlet weak var overviewValueLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderButton: UIButton!
    // MARK: - Variable
    var viewData: MainViewData.Robot!
    var presenter: RobotDetailPresenterProtocol!
    var pageVc: RobotDetailPageViewController?

    func inject(viewData: MainViewData.Robot) {
        self.viewData = viewData
        presenter = MainBuilder.RobotDetail().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let _ = presenter?.data.id else {
            addBlurView()
            return
        }
        displayNameValueLabel?.text = presenter?.displayName
        overviewValueLabel?.text = presenter?.overview
        robotTypeValueLabel?.text = presenter?.typeName
        robotTypeValueLabel?.isEnabled = true
        serialValueLabel?.text = toLabelText(presenter?.serialName)
        serialValueLabel?.isEnabled = hasLabelText(presenter?.serialName)
        overviewValueLabel?.showSkeleton()
        presenter?.image {
            guard let data = $0 else { return }
            self.robotImageView?.image = UIImage(data: data)
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        containerViewHeight?.constant = container.preferredContentSize.height
    }
}

// MARK: - View Controller Event
extension RobotDetailViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.Main(segue) {
        case .containerPage:
            guard let data = presenter?.data else { return }
            pageVc = segue.destination as? RobotDetailPageViewController
            pageVc?._delegate = self
            pageVc?.inject(viewData: data)
        default: break
        }
    }
}

// MARK: - Action
extension RobotDetailViewController {

    @IBAction private func selectorMoreBarButtonItem(_ sender: UIBarButtonItem) {
        presenter?.tapMoreBarButton(sender)
    }

    @IBAction private func valueChangedSegment(_ sender: UISegmentedControl) {
        pageVc?.changePage(index: sender.selectedSegmentIndex)
    }

    @IBAction private func touchUpInsideOrderButton(_ sender: UIButton) {
        presenter?.tapOrderEntryButton()
    }
}

// MARK: - Interface Function
extension RobotDetailViewController: RobotDetailViewControllerProtocol {

    func showActionSheet(_ button: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        alertController.addAction(UIAlertAction(title: L10n.calibrateToRobot, style: .default) { (_: UIAlertAction!) -> Void in
            // TODO: 仕様検討中
            self.presentAlert("Not yet implemented", "Comming Soon...")
        })

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = button
        }
        self.present(alertController, animated: true, completion: nil)
    }

    func pageChanged(index: Int) {
        segmentedControl?.selectedSegmentIndex = index
    }
    /// OrderEntry画面へ遷移
    func launchOrderEntry() {
        let navigationController = StoryboardScene.OrderEntry.initialScene.instantiate()
        if let vc = navigationController.topViewController as? OrderEntryJobSelectionViewController {
            vc.inject(jobId: nil, robotId: presenter?.data.id)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - Private Function
extension RobotDetailViewController {

    private func addBlurView() {

        guard let navigationController = self.navigationController else {
            return
        }

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.alpha = 0.9
        navigationController.view.addSubview(visualEffectView)
        visualEffectView.topAnchor.constraint(equalTo: navigationController.view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor).isActive = true

        let label = UILabel()
        label.text = L10n.selectARobotFromTheList
        label.font = .systemFont(ofSize: 24)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor).isActive = true
    }
}
