//
//  JobDetailViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobDetailViewControllerProtocol
/// @mockable
protocol JobDetailViewControllerProtocol: class {
    /// OrderEntryを起動
    func launchOrderEntry()
    /// ページ変更
    /// - Parameter index: インデックス
    func pageChanged(index: Int)
}

class JobDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    var viewData: MainViewData.Job!
    var presenter: JobDetailPresenterProtocol!
    var pageVc: JobDetailPageViewController?

    func inject(viewData: MainViewData.Job) {
        self.viewData = viewData
        presenter = MainBuilder.JobDetail().build(vc: self, viewData: viewData)
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
        displayNameLabel?.text = presenter?.displayName
        overviewLabel?.text = toLabelText(presenter?.overview)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        containerViewHeight?.constant = container.preferredContentSize.height
    }
}

// MARK: - View Controller Event
extension JobDetailViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.Main(segue) {
        case .containerPage:
            guard let data = presenter?.data else { return }
            pageVc = segue.destination as? JobDetailPageViewController
            pageVc?._delegate = self
            pageVc?.inject(viewData: data)
        default: break
        }
    }
}

// MARK: - Action
extension JobDetailViewController {

    @IBAction private func touchUpInsideOrderButton(_ sender: UIButton) {
        presenter?.tapOrderButton()
    }

    @IBAction private func valueChangedSegment(_ sender: UISegmentedControl) {
        pageVc?.changePage(index: sender.selectedSegmentIndex)
    }
}

// MARK: - Interface Function
extension JobDetailViewController: JobDetailViewControllerProtocol {

    func launchOrderEntry() {
        let navigationController = StoryboardScene.OrderEntry.initialScene.instantiate()
        if let vc = navigationController.topViewController as? OrderEntryJobSelectionViewController {
            vc.inject(jobId: presenter?.data.id, robotId: nil)
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    /// ページ変更
    /// - Parameter index: インデックス
    func pageChanged(index: Int) {
        segmentedControl?.selectedSegmentIndex = index
    }
}

// MARK: - Private Function
extension JobDetailViewController {

    private func addBlurView() {

        guard let navigationController = self.navigationController else { return }

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.alpha = 0.9
        navigationController.view.addSubview(visualEffectView)
        visualEffectView.topAnchor.constraint(equalTo: navigationController.view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor).isActive = true

        let label = UILabel()
        label.text = L10n.selectAJobFromTheList
        label.font = .systemFont(ofSize: 24)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.contentView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor).isActive = true
    }
}
