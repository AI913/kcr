//
//  RecognitionLibrarySelectionViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/19.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class WorkObjectLibrarySelectionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var workObjectLibraryCollection: UICollectionView!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Variable
    private var data: ActionEntryViewData!
    private var computedCellSize: CGSize?

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bottomButton?.isEnabled = false
    }

    func inject(data: ActionEntryViewData) {
        self.data = data
    }
}

// MARK: - View Controller Event
extension WorkObjectLibrarySelectionViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setWorks()
        switch StoryboardSegue.ActionEntry(segue) {
        case .toWorkObjectLibraryTest:
            if let vc = (segue.destination as! UINavigationController).topViewController as? WorkObjectLibraryTestViewController {
                vc.inject(data: data)
            }
        case .toWorkObjectSelection:
            if let vc = segue.destination as? WorkObjectSelectionViewController {
                vc.inject(data: data)
            }
        default: break
        }
    }
}

// MARK: - Implement UICollectionViewDataSource
extension WorkObjectLibrarySelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActionEntryViewData.WorkLibrary.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkObjectLibraryCollectionViewCell.identifier, for: indexPath)
        guard let cell = _cell as? WorkObjectLibraryCollectionViewCell else {
            return _cell
        }
        cell.setRow(indexPath)
        return cell
    }

}

// MARK: - Implement UICollectionViewDelegate
extension WorkObjectLibrarySelectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        data.workLibrary = ActionEntryViewData.WorkLibrary(index: indexPath.row)
        bottomButton?.isEnabled = true
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension WorkObjectLibrarySelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let size = computedCellSize {
            return size
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkObjectLibraryCollectionViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? WorkObjectLibraryCollectionViewCell, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 3)
        computedCellSize = cellSize

        return cellSize
    }
}

// MARK: - Action
extension WorkObjectLibrarySelectionViewController {

    @IBAction func returnActionForSegue(_ segue: UIStoryboardSegue) {
    }

    @IBAction private func selectorCancelBarButtonItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @IBAction private func touchDownSubmitButton(_ sender: UIButton) {
    }

    @IBAction private func touchDownTestButton(_ sender: UIButton) {
        data.workLibrary = ActionEntryViewData.WorkLibrary(index: sender.tag)
    }
}

// MARK: - Private Function
extension WorkObjectLibrarySelectionViewController {

    private func setup() {
        workObjectLibraryCollection?.allowsSelection = true
        subtitle?.text = L10n.WorkObjectLibrarySelection.subtitle
        bottomButton?.setTitle(L10n.WorkObjectLibrarySelection.bottomButton, for: .normal)
    }

    private func setWorks() {
        data.works = ActionEntryViewData.Work.allCases.filter {
            return data.workLibrary == .industrialParts ? $0.isIndustrialParts :
                data.workLibrary == .stationery ? $0.isStationery : false
        }.compactMap {
            let tray = data.destTray.count == 1 ? data.destTray[0] : nil
            return ActionEntryViewData.WorkAndTray(work: $0, tray: tray)
        }
    }
}
