//
//  ActionEntryActionLibrarySelectionViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/13.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class ActionEntryActionLibrarySelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var actionLibraryCollection: UICollectionView!
    @IBOutlet private weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Variable
    private var data: ActionEntryViewData = ActionEntryViewData()
    private var computedCellSize: CGSize?

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.ActionEntry(segue) {
        case .toWorkBenchEntry:
            if let vc = segue.destination as? WorkBenchEntryViewController {
                vc.inject(data: data)
            }
        default: break
        }
    }
}

// MARK: - Action
extension ActionEntryActionLibrarySelectionViewController {

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}

// MARK: - Implement UICollectionViewDataSource
extension ActionEntryActionLibrarySelectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActionEntryViewData.ActionLibrary.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionEntryActionLibraryCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? ActionEntryActionLibraryCollectionViewCell else {
            return _cell
        }
        cell.setRow(indexPath)
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegate
extension ActionEntryActionLibrarySelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bottomButton?.isEnabled = true
        data.actionLibrary = ActionEntryViewData.ActionLibrary(index: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        bottomButton?.isEnabled = false
        data.actionLibrary = nil
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension ActionEntryActionLibrarySelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let size = computedCellSize {
            return size
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionEntryActionLibraryCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? ActionEntryActionLibraryCollectionViewCell, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 3)
        computedCellSize = cellSize

        return cellSize
    }
}

// MARK: - Private Function
extension ActionEntryActionLibrarySelectionViewController {

    private func setup() {
        actionLibraryCollection?.allowsSelection = true
        navigationItem.leftBarButtonItem?.title = L10n.cancel
        navigationItem.title = L10n.ActionEntryActionLibrarySelection.title
        subtitle?.text = L10n.ActionEntryActionLibrarySelection.subtitle
        bottomButton?.setTitle(L10n.ActionEntryActionLibrarySelection.bottomButton, for: .normal)
    }
}
