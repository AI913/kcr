//
//  RobotListViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// RobotListViewControllerProtocol
/// @mockable
protocol RobotListViewControllerProtocol: class {
    /// RobotDetail画面へ遷移
    func transitionToRobotDetail()
    /// テーブルを更新
    func reloadTable()
}

class RobotListViewController: UITableViewController {

    private var searchText: String = ""

    // MARK: - Variable
    var presenter: RobotListPresenterProtocol!
    private let searchController = UISearchController()

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.RobotList().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = L10n.keyword
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.automaticallyShowsCancelButton = false
        tableView.tableHeaderView = self.searchController.searchBar
        // 初期表示時searchBarを隠す
        var contentOffset = tableView.contentOffset
        contentOffset.y = searchController.searchBar.frame.size.height
        tableView.contentOffset = contentOffset

        self.searchController.searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.searchController.searchBar.text = self.searchText
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.isActive = false
    }
}

// MARK: - View Controller Event
extension RobotListViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.Main(segue) {
        case .showRobotDetail:
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            let vc = (segue.destination as! UINavigationController).topViewController as! RobotDetailViewController
            vc.inject(viewData: MainViewData.Robot(id: presenter?.id(indexPath.row)))
            vc.navigationItem.leftItemsSupplementBackButton = true
        default: break
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension RobotListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRowsInSection ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: RobotListViewCell.identifier, for: indexPath)
        guard let cell = _cell as? RobotListViewCell else {
            return _cell
        }
        cell.inject(presenter: presenter)
        cell.setRow(indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        presenter?.selectRow(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchText = self.searchController.searchBar.text ?? ""
        self.searchController.isActive = false
    }
}

// MARK: - UISearchBarDelegate
extension RobotListViewController: UISearchBarDelegate {

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

// MARK: - Implement UISearchResultsUpdating
extension RobotListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterAndSort(keyword: searchController.searchBar.text, keywordChanged: true)
    }
}

// MARK: - Interface Function
extension RobotListViewController: RobotListViewControllerProtocol {

    func transitionToRobotDetail() {
        self.perform(segue: StoryboardSegue.Main.showRobotDetail)
    }

    func reloadTable() {
        self.tableView?.reloadData()
    }
}
