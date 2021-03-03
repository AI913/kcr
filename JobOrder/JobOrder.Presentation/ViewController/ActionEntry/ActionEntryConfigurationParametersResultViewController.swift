//
//  ActionEntryConfigurationParametersResultViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/24.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

/// ActionEntryConfigurationParametersResultViewController
/// @mockable
protocol ActionEntryConfigurationParametersResultViewControllerProtocol: class {}

class ActionEntryConfigurationParametersResultViewController: ActionEntryConfigurationContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var completeButton: UIButton!
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Variable
    var presenter: ActionEntryConfigurationParametersResultPresenterProtocol!

    //    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.font = UIFont.boldSystemFont(ofSize: 22)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

// MARK: - Implement UITableViewDataSource, UITableViewDelegate
extension ActionEntryConfigurationParametersResultViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: ActionEntryConfigurationParametersResultTableViewCell.identifier, for: indexPath)
        guard let cell = _cell as? ActionEntryConfigurationParametersResultTableViewCell else {
            return _cell
        }
        cell.inject(presenter: presenter)
        cell.setRow(indexPath)
        return cell
    }

    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        navigationController?.setNavigationBarHidden(false, animated: false)
    //        presenter?.selectRow(index: indexPath.row)
    //        tableView.deselectRow(at: indexPath, animated: true)
    //    }
}

extension ActionEntryConfigurationParametersResultViewController: ActionEntryConfigurationParametersResultViewControllerProtocol {}
