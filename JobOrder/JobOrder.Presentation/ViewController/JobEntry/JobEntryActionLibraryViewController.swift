//
//  JobEntryMenuViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/02.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit
/// JobEntryActionLibraryViewControllerProtocol
/// @mockable
protocol JobEntryActionLibraryViewControllerProtocol: class {
    /// RobotSelection画面へ遷移
    func transitionToAILibrarySelectionScreen()
    /// コレクションを更新
    func reloadCollection()
}

class JobEntryActionLibraryViewController: UIViewController, UIGestureRecognizerDelegate {

    private var searchText: String = ""

    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchController: UISearchBar!
    @IBAction func infoButtonTapped(_ sender: Any) {
        let tagNo:UIButton = sender as! UIButton
        print(tagNo.tag)
    }
    
    // MARK: - Variable
    var presenter: JobEntryActionLibraryPresenterProtocol!
    private var computedCellSize: CGSize?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = JobEntryBuilder.ActionLibrarySelection().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.layer.borderWidth = 1
        searchController.layer.borderColor = UIColor.gray.cgColor
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.gray.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - Implement UICollectionViewDataSource
extension JobEntryActionLibraryViewController: UICollectionViewDataSource {

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
        
        let selectBGView = UIView(frame: cell.frame)
        selectBGView.backgroundColor = .blue
        cell.selectedBackgroundView = selectBGView
        return cell
    }
}

// MARK: - Implement UICollectionViewDelegateFlowLayout
extension JobEntryActionLibraryViewController: UICollectionViewDelegateFlowLayout {

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
extension JobEntryActionLibraryViewController: JobEntryActionLibraryViewControllerProtocol {

    func transitionToAILibrarySelectionScreen() {
        self.perform(segue: StoryboardSegue.JobEntry.showAction)
    }

    func reloadCollection() {
        collectionView?.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension JobEntryActionLibraryViewController: UISearchBarDelegate {

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        presenter?.filterAndSort(keyword: self.searchText, keywordChanged: true)
    }
}

