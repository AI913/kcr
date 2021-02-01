//
//  JobListViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/17.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobListViewControllerProtocol
/// @mockable
protocol JobListViewControllerProtocol: class {
    /// JobDetail画面へ遷移
    func transitionToJobDetail()
    /// JobEntryを起動
    func launchJobEntry()
    /// テーブルを更新
    func reloadTable()
}

class JobListViewController: UITableViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var addButtonItem: UIBarButtonItem!

    // MARK: - Variable
    var presenter: JobListPresenterProtocol!
    var viewData: JobEntryViewData!
    private let searchController = UISearchController()

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = MainBuilder.JobList().build(vc: self)
    }
    
//    func inject(jobId: String?, robotId: String?) {
//        self.viewData = JobEntryViewData(jobId, robotId)
//        presenter = MainBuilder.JobList().build(vc: self)
//    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = L10n.keyword
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? false
        super.viewWillAppear(animated)
    }
}

// MARK: - View Controller Event
extension JobListViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.Main(segue) {
        case .showJobDetail:
            guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
            let vc = (segue.destination as! UINavigationController).topViewController as! JobDetailViewController
            vc.inject(viewData: MainViewData.Job(id: presenter?.id(indexPath.row)))
            vc.navigationItem.leftItemsSupplementBackButton = true
        default: break
        }
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension JobListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRowsInSection ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: JobListViewCell.identifier, for: indexPath)
        guard let cell = _cell as? JobListViewCell else {
            return _cell
        }
        cell.inject(presenter: presenter)
        cell.setRow(indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectRow(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Action
extension JobListViewController {

    @IBAction private func selectorAddBarButtonItem(_ sender: UIBarButtonItem) {
        presenter?.tapAddButton()
    }
}

// MARK: - Implement UISearchResultsUpdating
extension JobListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        presenter?.filterAndSort(keyword: searchController.searchBar.text, keywordChanged: true)
    }
}

// MARK: - Interface Function
extension JobListViewController: JobListViewControllerProtocol {

    func transitionToJobDetail() {
        self.perform(segue: StoryboardSegue.Main.showJobDetail)
    }

    func launchJobEntry() {
        let navigationController = StoryboardScene.JobEntry.initialScene.instantiate()
        if let vc = navigationController.topViewController as? JobEntryGeneralInformationFormViewController {
            vc.inject()
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    func reloadTable() {
        self.tableView.reloadData()
    }
}
