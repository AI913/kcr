//
//  OrderEntryRobotSelectionViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// OrderEntryRobotSelectionViewControllerProtocol
/// @mockable
protocol OrderEntryRobotSelectionViewControllerProtocol: class {
    /// ConfigurationForm画面へ遷移
    func transitionToConfigurationFormScreen()
    /// コレクションを更新
    func reloadCollection()
}

class OrderEntryRobotSelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var robotCollection: UICollectionView!
    @IBOutlet weak var continueButton: UIButton!

    // MARK: - Variable
    var viewData: OrderEntryViewData!
    var presenter: OrderEntryRobotSelectionPresenterProtocol!
    private var computedCellSize: CGSize?

    func inject(viewData: OrderEntryViewData) {
        self.viewData = viewData
        presenter = OrderEntryBuilder.RobotSelection().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
        robotCollection?.allowsSelection = true
        robotCollection?.allowsMultipleSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }
}

// MARK: - View Controller Event
extension OrderEntryRobotSelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.OrderEntry(segue) {
        case .showConfigurationForm:
            guard let data = presenter?.data else { return }
            (segue.destination as! OrderEntryConfigurationFormViewController).inject(viewData: data)
        default: break
        }
    }
}

// MARK: - Implement UICollectionViewDataSource
extension OrderEntryRobotSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderEntryRobotSelectionRobotCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? OrderEntryRobotSelectionRobotCollectionViewCell else {
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
extension OrderEntryRobotSelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.selectItem(indexPath: indexPath)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        presenter?.selectItem(indexPath: indexPath)
        continueButton?.isEnabled = presenter?.isEnabledContinueButton ?? false
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension OrderEntryRobotSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard self.computedCellSize == nil else {
            return self.computedCellSize!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderEntryRobotSelectionRobotCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? OrderEntryRobotSelectionRobotCollectionViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionViewCell is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        self.computedCellSize = cellSize
        return cellSize
    }
}

// MARK: - Action
extension OrderEntryRobotSelectionViewController {

    @IBAction private func touchUpInsideContinueButton(_ sender: UIButton) {
        presenter?.tapContinueButton()
    }
}

// MARK: - Protocol Function
extension OrderEntryRobotSelectionViewController: OrderEntryRobotSelectionViewControllerProtocol {

    func transitionToConfigurationFormScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showConfigurationForm)
    }

    func reloadCollection() {
        robotCollection?.reloadData()
    }
}
