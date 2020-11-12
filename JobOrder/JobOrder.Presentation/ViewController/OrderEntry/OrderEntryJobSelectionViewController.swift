//
//  OrderEntryJobSelectionViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// OrderEntryJobSelectionViewControllerProtocol
/// @mockable
protocol OrderEntryJobSelectionViewControllerProtocol: class {
    /// RobotSelection画面へ遷移
    func transitionToRobotSelectionScreen()
    /// コレクションを更新
    func reloadCollection()
}

class OrderEntryJobSelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var jobCollection: UICollectionView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var continueButton: UIButton!

    // MARK: - Variable
    var viewData: OrderEntryViewData!
    var presenter: OrderEntryJobSelectionPresenterProtocol!
    private var computedCellSize: CGSize?

    func inject(jobId: String?, robotId: String?) {
        self.viewData = OrderEntryViewData(jobId, robotId)
        presenter = OrderEntryBuilder.JobSelection().build(vc: self, viewData: self.viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        jobCollection?.allowsSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }
}

// MARK: - View Controller Event
extension OrderEntryJobSelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.OrderEntry(segue) {
        case .showRobotSelection:
            guard let data = presenter?.data else { return }
            (segue.destination as! OrderEntryRobotSelectionViewController).inject(viewData: data)
        default: break
        }
    }
}

// MARK: - Implement UICollectionViewDataSource
extension OrderEntryJobSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderEntryJobSelectionJobCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? OrderEntryJobSelectionJobCollectionViewCell else {
            return _cell
        }

        cell.inject(presenter: presenter)
        cell.setItem(indexPath)
        if let presenter = presenter, presenter.isSelected(indexPath: indexPath) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegate
extension OrderEntryJobSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.selectItem(indexPath: indexPath)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension OrderEntryJobSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard computedCellSize == nil else {
            return computedCellSize!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderEntryJobSelectionJobCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? OrderEntryJobSelectionJobCollectionViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        computedCellSize = cellSize
        return cellSize
    }
}

// MARK: - Action
extension OrderEntryJobSelectionViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func touchUpInsideContinueButton(_ sender: UIButton) {
        presenter?.tapContinueButton()
    }
}

// MARK: - Protocol Function
extension OrderEntryJobSelectionViewController: OrderEntryJobSelectionViewControllerProtocol {

    func transitionToRobotSelectionScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showRobotSelection)
    }

    func reloadCollection() {
        jobCollection?.reloadData()
    }
}
