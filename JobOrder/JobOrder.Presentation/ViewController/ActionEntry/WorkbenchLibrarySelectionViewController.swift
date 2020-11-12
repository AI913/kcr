//
//  WorkbenchLibrarySelectionViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkbenchLibrarySelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var workbenchLibraryCollection: UICollectionView!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Variable
    private var data: ActionEntryViewData!
    private var computedCellSize: CGSize?

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomButton?.isEnabled = false
    }

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - View Controller Event
extension WorkbenchLibrarySelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.ActionEntry(segue) {
        case .unwindToWorkbenchEntry:
            if let vc = segue.destination as? WorkBenchEntryViewController {
                vc.inject(data: data)
            }
        default: break
        }
    }
}

// MARK: - Implement UICollectionViewDataSource
extension WorkbenchLibrarySelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActionEntryViewData.WorkBenchLibrary.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkbenchLibraryCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkbenchLibraryCollectionViewCell else {
            return _cell
        }
        cell.setRow(indexPath)
        return cell
    }

}

// MARK: - Implement UICollectionViewDelegate
extension WorkbenchLibrarySelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bottomButton?.isEnabled = true
        data.workbenchLibrary = ActionEntryViewData.WorkBenchLibrary(index: indexPath.row)
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension WorkbenchLibrarySelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let size = computedCellSize {
            return size
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkbenchLibraryCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? WorkbenchLibraryCollectionViewCell, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 3)
        computedCellSize = cellSize

        return cellSize
    }
}

// MARK: - Action
extension WorkbenchLibrarySelectionViewController {

    @IBAction private func returnActionForSegue(_ segue: UIStoryboardSegue) {
    }

    @IBAction private func touchUpInsideSubmitButton(_ sender: UIButton) {
    }
}

// MARK: - Private Function
extension WorkbenchLibrarySelectionViewController {

    private func setup() {
        workbenchLibraryCollection?.allowsSelection = true
        subtitle?.text = L10n.WorkBenchLibrarySelection.subtitle
        bottomButton?.setTitle(L10n.WorkBenchLibrarySelection.bottomButton, for: .normal)
    }
}
