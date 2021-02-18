//
//  JobEntrySearchViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/03.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit
/// JobEntrySearchViewControllerProtocol
/// @mockable
protocol JobEntrySearchViewControllerProtocol: class {
    /// RobotSelection画面へ遷移
    func transitionToAILibrarySelectionScreen()
    /// コレクションを更新
    func reloadCollection()
}

class JobEntrySearchViewController: UIViewController {

    private var searchText: String = ""
    private let searchBarHeight: CGFloat = 44

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variable
    var presenter: JobEntrySearchPresenterProtocol!
    private let searchController = UISearchController()
    private var computedCellSize: CGSize?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = JobEntryBuilder.ActionLibrarySelection().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = L10n.keyword
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.automaticallyShowsCancelButton = false
        self.searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: searchBarHeight)
        self.searchController.hidesNavigationBarDuringPresentation = false
        collectionView.addSubview(self.searchController.searchBar)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Implement UICollectionViewDataSource
extension JobEntrySearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfItemsInSection ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobEntryActionLibraryViewCell.identifier, for: indexPath)
        guard let cell = _cell as? JobEntryActionLibraryViewCell else {
            return _cell
        }

        cell.inject(presenter: presenter)
        cell.setItem(indexPath)
        self.searchController.searchBar.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: searchBarHeight)
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension JobEntrySearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard computedCellSize == nil else {
            return computedCellSize!
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JobEntryActionLibraryViewCell.identifier, for: indexPath)
        guard let prototypeCell = cell as? JobEntryActionLibraryViewCell,
              let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("CollectionView is not found.")
        }

        let cellSize = prototypeCell.propotionalScaledSize(for: flowLayout, numberOfColumns: 2)
        computedCellSize = cellSize
        return cellSize
    }
}

// MARK: - Protocol Function
extension JobEntrySearchViewController: JobEntrySearchViewControllerProtocol {

    func transitionToAILibrarySelectionScreen() {
        self.perform(segue: StoryboardSegue.JobEntry.showAction)
    }

    func reloadCollection() {
        collectionView?.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension JobEntrySearchViewController: UISearchBarDelegate {

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

// MARK: - Implement UISearchResultsUpdating
extension JobEntrySearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterAndSort(keyword: searchController.searchBar.text, keywordChanged: true)
    }
}
